"""Convert captured GD frames to PNG and group observed glyph writes (no OCR)."""
from pathlib import Path
import struct
import zlib
import sys
import json

ROOT = Path(__file__).resolve().parent
case_name = sys.argv[1] if len(sys.argv)>1 else 'research-check'
CASE = (ROOT/'test'/case_name).resolve()
if not CASE.is_relative_to((ROOT/'test').resolve()):
    raise ValueError('Case outside test')

def chunk(kind, data):
    return struct.pack('>I', len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data))

for f in CASE.glob('*.gd'):
    d = f.read_bytes()
    w,h = struct.unpack_from('>HH',d,2)
    if len(d) != 11+4*w*h:
        raise ValueError('Unexpected GD format')
    rgba = d[11:]
    scan = bytearray()
    for y in range(h):
        scan.append(0)
        for x in range(w):
            pos = (y*w+x)*4
            scan.extend(rgba[pos+1:pos+4])
    f.with_suffix('.png').write_bytes(b'\x89PNG\r\n\x1a\n'+
        chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+
        chunk(b'IDAT',zlib.compress(scan))+chunk(b'IEND',b''))

# US alphabet is a hypothesis for this translation, not a verified Spanish table.
chars = {128:' '}
chars.update({129+i:c for i,c in enumerate('abcdefghijklmnopqrstuvwxyz')})
chars.update({155+i:c for i,c in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ')})
chars.update({181+i:c for i,c in enumerate('0123456789')})
chars.update({191:'.',192:',',193:'/',194:"'",195:'[',196:']',197:':',198:'-',200:'!',202:'?'})
lines=[]
current=[]
previous=None
start=None
for row in (CASE/'glyphs.tsv').read_text().splitlines()[1:]:
    frame,glyph,x=map(int,row.split('\t'))
    if previous is not None and x<=previous:
        lines.append(dict(frame=start, hypothesis=''.join(current)))
        current=[]
    if not current:
        start=frame
    current.append(chars.get(glyph,f'<{glyph:02X}>'))
    previous=x
if current:
    lines.append(dict(frame=start,hypothesis=''.join(current)))
(CASE/'text-hypothesis.json').write_text(json.dumps(lines,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(lines,ensure_ascii=False,indent=2))
