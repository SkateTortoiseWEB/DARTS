#!/usr/bin/env python3
"""Make an Oche caller voice pack with Kokoro, a free AI voice that runs on your own computer.

Kokoro's model is Apache-2.0 licensed, so the clips can be shared with the app or sold with kits.

Setup (once, on a Mac):
    python3 -m venv ~/oche-voice && source ~/oche-voice/bin/activate
    pip install kokoro soundfile
    brew install espeak-ng          # helps with unusual words; optional

Try a few voices first (writes a handful of clips per voice into ./voice-preview):
    python3 make_voice_pack.py --preview

Make the full pack (417 clips) with the voice you like:
    python3 make_voice_pack.py --voice bm_george --out ~/Desktop/oche-voice-george

Then in Oche: Settings > Sound and display > Load voice pack, and choose that folder.
British voices: bm_george, bm_lewis, bm_daniel, bm_fable (male); bf_emma, bf_isabella, bf_alice, bf_lily (female).
"""
import argparse
import os
import shutil
import subprocess
import sys

ONES = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
        'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen']
TENS = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety']


def words(n):
    """Numbers the way a British caller says them (same as Oche's own caller text)."""
    if n < 20:
        return ONES[n]
    if n < 100:
        return TENS[n // 10] + ('-' + ONES[n % 10] if n % 10 else '')
    r = n % 100
    return 'one hundred' + (' and ' + words(r) if r else '')


def cap(s):
    return s[0].upper() + s[1:]


def lines():
    """Every clip Oche plays: file name (without extension) -> what's said. 417 in total."""
    out = {}
    for n in range(1, 21):
        out[f'dart_{n}'] = cap(words(n))
        out[f'dart_D{n}'] = 'Double ' + words(n)
        out[f'dart_T{n}'] = 'Treble ' + words(n)
    out['dart_25'] = 'Twenty-five'
    out['dart_Bull'] = 'Bullseye'
    out['dart_Miss'] = 'No score'
    for n in range(0, 181):
        out[f'total_{n}'] = 'No score' if n == 0 else 'One hundred and eighty!' if n == 180 else cap(words(n))
    for n in range(2, 171):
        out[f'require_{n}'] = 'You require ' + words(n)
    out['gameon'] = 'Game on!'
    out['bust'] = 'Bust!'
    out['leg'] = 'Game shot, and the leg!'
    out['match'] = 'Game shot, and the match!'
    return out


PREVIEW_KEYS = ['total_180', 'total_100', 'total_41', 'require_121', 'dart_T20', 'bust', 'match']


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--voice', default='bm_george', help='Kokoro voice (default bm_george)')
    ap.add_argument('--speed', type=float, default=1.0, help='speaking speed, e.g. 0.9 for slower (default 1.0)')
    ap.add_argument('--out', default='oche-voice', help='folder to write the clips into')
    ap.add_argument('--preview', action='store_true', help='write a few clips for each British voice to compare them')
    ap.add_argument('--wav', action='store_true', help="keep WAV files (default: convert to smaller .m4a if the Mac's afconvert is there)")
    a = ap.parse_args()

    try:
        from kokoro import KPipeline
        import numpy as np
        import soundfile as sf
    except ImportError:
        sys.exit('Kokoro isn\'t installed. Run: pip install kokoro soundfile')

    pipe = KPipeline(lang_code='b')   # b = British English
    todo = lines()
    assert len(todo) == 417, len(todo)
    afconvert = None if a.wav else shutil.which('afconvert')

    def render(text, voice, path):
        audio = [chunk for _, _, chunk in pipe(text, voice=voice, speed=a.speed)]
        wav = path + '.wav'
        sf.write(wav, np.concatenate(audio), 24000)
        if afconvert:   # AAC in .m4a: about a tenth of the size, plays everywhere
            subprocess.run([afconvert, '-f', 'm4af', '-d', 'aac', '-b', '64000', wav, path + '.m4a'], check=True)
            os.remove(wav)

    if a.preview:
        voices = ['bm_george', 'bm_lewis', 'bm_daniel', 'bm_fable', 'bf_emma', 'bf_isabella', 'bf_alice', 'bf_lily']
        for v in voices:
            d = os.path.join('voice-preview', v)
            os.makedirs(d, exist_ok=True)
            for k in PREVIEW_KEYS:
                render(todo[k], v, os.path.join(d, k))
            print('wrote', d)
        print('Listen to them, then make the full pack with --voice <name>.')
        return

    os.makedirs(a.out, exist_ok=True)
    for i, (key, text) in enumerate(todo.items(), 1):
        render(text, a.voice, os.path.join(a.out, key))
        if i % 25 == 0 or i == len(todo):
            print(f'{i}/{len(todo)}')
    print(f'Done. In Oche: Settings > Sound and display > Load voice pack, and choose {os.path.abspath(a.out)}')


if __name__ == '__main__':
    main()
