def printHello(num1, num2):
    for i in range(num1):
        for j in range(num2):
            print("Hello", end=" ")
        print()
def printHello2(num1, num2):
    for i in range(num1):
        for j in range(num2):
            print("Hello, World", end=" ")
        print()

if __name__ == '__main__':
    printHello(2,3)
    printHello2(1,2)



