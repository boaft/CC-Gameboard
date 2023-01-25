chess=peripheral.wrap("computer_5")

checkers=peripheral.wrap("computer_4")

egypt=peripheral.wrap("computer_6")

scrabble=peripheral.wrap("computer_7")

chess.turnOn()
os.sleep(2)
chess.shutdown()

checkers.turnOn()
os.sleep(2)
checkers.shutdown()

egypt.turnOn()
os.sleep(2)
egypt.shutdown()

scrabble.turnOn()
os.sleep(2)
scrabble.shutdown()
