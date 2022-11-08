# VHDL game code

import serial


def trans():
    # words of the regular game
    words = ["HI        ", "WAR       ", "LOVE      ", "PAPER     ", "ABROAD    ",
                           "ABILITY   ", "ABSTRACT  ", "TECHNIQUE ", "FRIENDSHIP"]
    # words of the fame to the video
    # words = ["HI        ", "FRIENDSHIP"]
    win_word = "WIN       "
    with serial.Serial('COM4', 115200, timeout=1) as ser:
        for i, word in enumerate(words):
            for letter in word:
                ser.write(letter.encode())
            r = b''
            while r != b'SUCCESS':
                r = ser.read(7)
            print(f'You passed level {i + 1}')
        for letter in win_word:
            ser.write(letter.encode())
    print("You won the game !")


if __name__ == "__main__":
    trans()
