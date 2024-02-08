import os
import time
from sys import argv
def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')


def replace_char_at_index(string: str, index: int, char: str):
    return string[:index] + char.upper()  + string[index + 1:]

def animate_text(text: str, delay=0.1):
    for i in range(len(text)):
        clear_screen()
        print(replace_char_at_index(text.lower(), i, text[i]))
        time.sleep(delay)

text = argv[1] if argv[1:] else "Hello World!"

def main():
    try:
        while True:
            animate_text(text, delay=0.1)
    except KeyboardInterrupt:
        print("Exiting...")


if __name__ == "__main__":
    main()
