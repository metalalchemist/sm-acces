"""Test project isolation without a real ROM, game addresses or running emulator."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
FILES = ['snes9x.exe', 'lua51.dll', 'lua5.1.dll', 'Valid.Ext']
CONFIG = '''Mute = FALSE
PauseWhenInactive = TRUE
Input:Background = OFF
Dir:Savestates = USER_SAVES
Dir:SRAM = USER_SAVES
Dir:Roms = USER_ROMS
Dir:Cheats = USER_CHEATS
Dir:Patches = USER_PATCHES
Dir:Screenshots = USER_SCREENSHOTS
Dir:Movies = USER_MOVIES
'''


@unittest.skipUnless(os.name == 'nt', 'Manager targets Windows PowerShell and Snes9x Lua')
class ManagerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='snes-manager-test-')
        self.base = Path(self.temp.name).resolve()
        self.source = self.base / 'source'
        self.source.mkdir()
        for name in FILES:
            (self.source / name).write_bytes(('fixture-' + name).encode())
        self.config = self.source / 'base.conf'
        self.config.write_text(CONFIG)

    def tearDown(self):
        assert self.base.parent == Path(tempfile.gettempdir()).resolve()
        assert self.base.name.startswith('snes-manager-test-')
        self.temp.cleanup()

    def project(self, name, rom=b'fake ROM for manager unit tests'):
        root = self.base / name
        tests = root / 'tests'
        tests.mkdir(parents=True)
        for filename in ['emulador-pruebas.ps1', 'enable-background.ps1', 'smoke.lua']:
            shutil.copy2(HERE / filename, tests / filename)
        rom_path = root / 'own-game.sfc'
        rom_path.write_bytes(rom)
        data = dict(schema=1, profile='snes9x-lua-1.63-windows', project_id=name,
                    rom_path=str(rom_path), rom_sha256=hashlib.sha256(rom).hexdigest(),
                    emulator_dir=str(self.source), config_template=str(self.config))
        (tests / 'project.json').write_text(json.dumps(data), encoding='utf8')
        return tests

    def run_ps(self, tests, *args):
        return subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass',
                               '-File', str(tests / 'emulador-pruebas.ps1'), *args],
                              capture_output=True, text=True, errors='replace', timeout=30)

    def prepare_case(self, tests):
        result = self.run_ps(tests, '-Action', 'Start', '-Case', 'smoke-check',
                             '-Script', 'smoke.lua', '-PrepareOnly')
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_two_games_have_independent_rom_saves_config_and_commands(self):
        first = self.project('earthbound-access', b'game one')
        second = self.project('illusion-access', b'game two')
        for tests in [first, second]:
            self.prepare_case(tests)
            config = (tests / 'emulator/snes9x.conf').read_text()
            self.assertIn(str(tests / 'smoke-check/Saves'), config)
            other = second if tests == first else first
            self.assertNotIn(str(other), config)
            self.assertIn('Mute = TRUE', config)
            self.assertIn(str(tests / 'smoke-check/Screenshots'), config)
            self.assertNotIn('USER_SCREENSHOTS', config)
            self.assertNotIn('USER_MOVIES', config)
            wrapper = (tests / 'emulator/game.lua').read_text()
            self.assertIn(tests.parent.name, wrapper)
            self.assertNotIn('CHRONO', wrapper)
        self.assertNotEqual((first / 'emulator/Roms/game.sfc').read_bytes(),
                            (second / 'emulator/Roms/game.sfc').read_bytes())
        (first / 'smoke-check/Saves').mkdir(exist_ok=True)
        sentinel = first / 'smoke-check/Saves/keep.srm'
        sentinel.write_bytes(b'independent save')
        self.assertEqual(self.run_ps(second, '-Action', 'Stop').returncode, 0)
        self.assertEqual(sentinel.read_bytes(), b'independent save')
        self.assertEqual(self.config.read_text(), CONFIG)
        self.assertFalse((first / 'own-game.lua').exists())

    def test_entry_code_is_frozen_executed_and_archived_after_source_edit(self):
        tests = self.project('frozen-code')
        original = (tests / 'smoke.lua').read_bytes()
        session = self.prepare_case(tests)
        runtime = tests / 'emulator'
        frozen = runtime / 'executed-script.lua'
        self.assertEqual(frozen.read_bytes(), original)
        wrapper = (runtime / 'game.lua').read_text()
        self.assertIn(str(frozen).replace('\\', '/'), wrapper)
        self.assertNotIn(str(tests / 'smoke.lua').replace('\\', '/'), wrapper)
        (tests / 'smoke.lua').write_text('-- source edited after preparation')
        self.assertEqual(self.run_ps(tests, '-Action', 'Stop').returncode, 0)
        archived = Path(session['archive']) / 'executed-script.lua'
        self.assertEqual(archived.read_bytes(), original)
        hashes = json.loads((Path(session['archive']) / 'input-hashes.json').read_text(encoding='utf-8-sig'))
        self.assertEqual(hashes['script'].lower(), hashlib.sha256(original).hexdigest())

    def test_rom_hash_mismatch_refuses_preparation(self):
        tests = self.project('wrong-rom')
        (tests.parent / 'own-game.sfc').write_bytes(b'changed')
        result = self.run_ps(tests, '-Action', 'Prepare')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((tests / 'emulator/snes9x.exe').exists())

    def test_foreign_owner_never_gets_adopted(self):
        tests = self.project('first')
        self.prepare_case(tests)
        owner = tests / 'emulator/owner.json'
        data = json.loads(owner.read_text(encoding='utf-8-sig'))
        data['project'] = 'another-game'
        owner.write_text(json.dumps(data))
        self.assertNotEqual(self.run_ps(tests, '-Action', 'Stop').returncode, 0)
        self.assertTrue(owner.exists())

    def test_paths_outside_tests_are_rejected(self):
        tests = self.project('paths')
        for args in [('-Action', 'Start', '-Case', '../outside', '-Script', 'smoke.lua', '-PrepareOnly'),
                     ('-Action', 'Start', '-Case', 'smoke-check', '-Script', '../outside.lua', '-PrepareOnly'),
                     ('-Action', 'Stop', '-Instance', '../outside')]:
            with self.subTest(args=args):
                self.assertNotEqual(self.run_ps(tests, *args).returncode, 0)

    def test_recycled_or_foreign_pid_is_not_operated(self):
        tests = self.project('pid-check')
        self.prepare_case(tests)
        active = tests / 'emulator/active.json'
        data = json.loads(active.read_text(encoding='utf-8-sig'))
        data.update(processId=os.getpid(), startTicks=1)
        active.write_text(json.dumps(data))
        self.assertNotEqual(self.run_ps(tests, '-Action', 'Stop').returncode, 0)
        self.assertTrue(active.exists())

    def test_stop_preserves_case_saves_and_archives_temporary_evidence(self):
        tests = self.project('temporary')
        result = self.run_ps(tests, '-Action', 'Start', '-Case', 'smoke-check',
                             '-Script', 'smoke.lua', '-Temporary', '-PrepareOnly')
        self.assertEqual(result.returncode, 0, result.stderr)
        session = json.loads(result.stdout)
        runtime = tests / 'emulator-temp' / session['instance']
        (runtime / 'evidence.txt').write_text('keep this')
        save = tests / 'smoke-check/Saves/keep.srm'
        save.write_bytes(b'case save')
        stopped = self.run_ps(tests, '-Action', 'Stop', '-Instance', session['instance'])
        self.assertEqual(stopped.returncode, 0, stopped.stderr)
        self.assertFalse(runtime.exists())
        self.assertEqual((Path(session['archive']) / 'evidence.txt').read_text(), 'keep this')
        self.assertEqual(save.read_bytes(), b'case save')


if __name__ == '__main__':
    unittest.main()
