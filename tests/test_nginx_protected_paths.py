"""Actual NGINX routing checks. Requires Docker, openssl, curl, and Jinja2.
Set NGINX_TEST_IMAGE to an available NGINX image; tests never pull implicitly.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest
from jinja2 import Environment, StrictUndefined

TEMPLATE = Path(__file__).resolve().parents[1] / 'ansible/roles/nginx/templates/openemr.conf.j2'
IMAGE = os.environ.get('NGINX_TEST_IMAGE', 'nginx:stable-alpine')

def run(*args):
    return subprocess.run(args, check=True, text=True, capture_output=True).stdout.strip()

class ProtectedPathsTest(unittest.TestCase):
    def check_server(self, domain):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            root.chmod(0o755)
            for protected in ('documents', 'edi', 'era'):
                for extension in ('js', 'css', 'png', 'jpg', 'jpeg', 'gif', 'ico', 'php', 'txt'):
                    file = root / f'www/sites/default/{protected}/stored.{extension}'
                    file.parent.mkdir(parents=True, exist_ok=True)
                    file.write_text('private fixture')
            public = root / 'www/public.js'
            public.write_text('public fixture')
            cert = root / 'certificate.pem'
            key = root / 'key.pem'
            run('openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes', '-days', '1',
                '-subj', '/CN=localhost', '-keyout', str(key), '-out', str(cert))
            text = Environment(undefined=StrictUndefined).from_string(TEMPLATE.read_text()).render(
                nginx_domain=domain, openemr_web_root='/fixtures/www')
            text = text.replace('/etc/letsencrypt/live/localhost/fullchain.pem', '/fixtures/certificate.pem')
            text = text.replace('/etc/letsencrypt/live/localhost/privkey.pem', '/fixtures/key.pem')
            config = root / 'default.conf'
            config.write_text(text)
            container = run('docker', 'run', '--rm', '-d',
                '-p', '127.0.0.1::80', '-p', '127.0.0.1::443',
                '-v', f'{root}:/fixtures:ro',
                '-v', f'{config}:/etc/nginx/conf.d/default.conf:ro', IMAGE)
            try:
                run('docker', 'exec', container, 'nginx', '-t')
                port = run('docker', 'port', container, '443/tcp' if domain else '80/tcp').split(':')[-1]
                base = f'{"https" if domain else "http"}://127.0.0.1:{port}'
                def status(path):
                    return run('curl', '-k', '--silent', '--show-error', '--max-time', '3',
                               '-o', '/dev/null', '-w', '%{http_code}', base + path)
                for attempt in range(30):
                    try:
                        self.assertEqual(status('/public.js'), '200')
                        break
                    except subprocess.CalledProcessError:
                        if attempt == 29: raise
                        time.sleep(0.1)
                for protected in ('documents', 'edi', 'era'):
                    for extension in ('js', 'css', 'png', 'jpg', 'jpeg', 'gif', 'ico', 'php', 'txt'):
                        self.assertEqual(status(f'/sites/default/{protected}/stored.{extension}'), '403')
                self.assertEqual(status('/sites/default/Documents/stored.JS'), '403')
                if domain:
                    http_port = run('docker', 'port', container, '80/tcp').split(':')[-1]
                    redirect = run('curl', '--silent', '--show-error', '--max-time', '3', '-o', '/dev/null',
                                   '-w', '%{http_code}', f'http://127.0.0.1:{http_port}/sites/default/documents/stored.js')
                    self.assertEqual(redirect, '301')
            finally:
                run('docker', 'stop', container)

    def test_http_protects_existing_private_files(self): self.check_server('')
    def test_https_protects_existing_private_files(self): self.check_server('localhost')

if __name__ == '__main__': unittest.main()
