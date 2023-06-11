# # 문자열 포맷팅

# a, b, c, d = 3, 4, 5, 6 #이러면 안 예쁘잖아
# print("a is", a, "b is ", b, "c is", c, "d is", d)

# i = 3
# temp = "this is %d" % 5 #%d : int
# print("this is %d" % i)

# # 방법 1)
# temp = "This is %d" % 5
# print(temp)

# temp = "This is %s" % "name" #%s : str
# print(temp)

# temp = "This is %f" % 1.245 #%f : float(6 digits), %.nf : float(n digits)
# print(temp)

# print()

# for i in range(8, 13):
#     print("====== %2d ======"%i) #%nd : int(n digits)

# print()

# for i in range(8, 13):
#     print("====== %-2d ======"%i) #%-nd : int(n digits + right align)

# print()

# for i in range(8, 13):
#     print("This is %.3f"%(i/10))

# print()



# # 방법 2)
# temp = "This is {} abc".format([1,2,3])
# print(temp)

# temp = "This is {} abc {}".format(5, 12) #set 첫번째 값(5)이 {}1, 두번째 값(12)가 {}2에 입력
# print(temp)

# temp = "This is {2} {0} {1} {0} {0}".format("hi", 3, 1.2) #{} index 호출
# print(temp)

# print()



# # 방법 3)
# a = "hi"
# b = 5
# c = 1.56

# temp = f"This is {b} {a}" #f':사전에 선언된 given variants 중에서 선택하여 중괄호에 기입
# print(temp)



# # 파일 쓰기

# # 예시 1)
# f = open("test1.txt", "w")
# f.write("Hello\n")
# f.write("World")
# f.close()

# # 예시 2)
# with open("test2.txt", "w") as f:
#     f.write("Hello\n")
#     f.write("World")

# # 연습 1)
# # 숫자 1~10을 "test3.txt" 파일에 한줄씩 입력하시오.
# with open("FY2021//test3.txt", "w") as f: #root 하위폴더로 path를 써주면 생성은 가능하지만, 폴더를 생성할 순 없다.
#     for i in range(10):
#         f.write(f"{i+1}\n")







# # 파일 읽기

# # 예시 1)
# with open("FY2021//test3.txt", "r") as f:
#     output = f.read()
#     # print([output])
#     print(output.split["/n"]) #개행문자 기준으로 list 형식으로 각 element 처리

# with open("FY2021//test3.txt", "r") as f:
#     output = f.readlines()
#     print(output)

# print()

# with open("FY2021//test3.txt", "r") as f:
#     for i in range(10):
#         output = f.readline()
#         print([output])

# print()

# with open("test3.txt", "r") as f:
#     while True:
#         output = f.readline()
#         if not output:
            #    print([output]) #마지막에 공백이 있는 rows까지 list로 표시해줌
#             break
#         print(output.rstrip()) #strip(양 끝의 공백, 개행문자 제거), lstrip, rstrip

# print()

# with open("test3.txt", "r") as f:
#     while True:
#         output = f.readline()
#         if not output:
#             break
#         output = output.rstrip()
#         print(output)

# test 4 파일생성과 읽어와서 리스트업
with open("FY2021//test4.txt", "w") as f:
    for i in range(10):
        if i == 9:
            f.write("%2d %2d %2d" % (i+1,i+2,i+3))
            break
        f.write("%2d %2d %2d\n" % (i+1,i+2,i+3)) #f.write(f"{i+1} {i+2} {i+3}\n")

dataset = []
with open("FY2021//test4.txt", "r") as f:
    dataset = f.readlines()
    for line in dataset:
        splitted = line.split(" ")
        sum = 0
        for word in splitted:
            if word:
                sum += int(word.rstrip())
        print(sum) #각 열별로 숫자를 합산하세요


# # 연습 0) 제공된 ex0.txt를 읽어 내용을 그대로 복사해 dst.txt에 작성하시오.

# # 연습 1) 제공된 ex1.txt에는 각 줄에 정수 하나가 작성되어 있다.
# # 그 수들의 평균값을 구해서 출력하시오.

# # 연습 2)
# # 예시로 제공한 파일 ex2.txt는 각 줄에 정수들이 작성되어 있다.
# # 각 줄에 작성되어 있는 정수들의 개수는 줄마다 다르다.
# # 각 줄의 평균값을 구해서 출력하시오.

# # 연습 3)
# # 예시로 제공한 파일 ex3.txt는 각 줄에 정수들이 정해진 개수만큼 작성되어 있다.
# # 줄이 아닌 각 열의 평균값을 구해서 출력하시오.







# # 예외 처리

# # 예시 1)
a = [1,2,3]
try:
    a[4] = 5
except:
    print("Error")

# # 예시 2)
# try:
#     5/0
# except:
#     print("Error")

# # 예시 3)
# try:
#     5/0
# except ZeroDivisionError:
#     print("00 Error")

# # 예시 4)
# try:
#     5/0
# except ZeroDivisionError as e:
#     print("Error:", e)

# # 예시 5)
# try:
#     a = [1,2,3]
#     a[4] = 5
# except IndexError as e:
#     print("Error:", e)

# # 예시 6)
# try:
#     a = [1,2,3]
#     a[4] = 5
# except ZeroDivisionError as e:
#     print("Zero Error:", e)
# except IndexError as e:
#     print("Index Error:", e)

# # 예시 7)
# try:
#     age = int(input("나이를 입력하세요: "))
# except:
#     print("Invalid Input")
# else:
#     print("당신의 나이는",age)

# # 예시 8)
# try:
#     f = open("test1.txt", "r")
#     lines = f.readlines()
#     data = int(lines[0])
#     f.close()
# except:
#     print("Error")
# finally:
#     print("Done")
#     f.close()