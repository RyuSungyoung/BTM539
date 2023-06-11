# 하샤드 수 문제풀이
# 첫번째 방법
def solution(x):
    sum = 0
    for i in str(x):
        sum += int(i)
    if x%sum:
        return False
    else:
        return True
# 두번째 방법
def solution(x):
    a=x
    sum = 0
    while a!=0:
        sum += (a%10)
        a //= 10
    if x%sum:
        return False
    else:
        return True


# 콜라츠 추측 문제풀이
def solution(num):
    for i in range(500):
        if num==1:
            return i
        if num%2:
            num = num*3 + 1
        else:
            num /= 2
    if num==1:
        return 500
    else:
        return -1


# 3진법 뒤집기 문제풀이
def solution(n):
    answer = 0
    temp = []
    while n:
        temp.append(n%3)
        n //= 3
    l = len(temp)
    for i in range(l):
        answer += temp[i] * (3**(l-1-i))
    return answer


# 문자열 뒤집기 문제풀이
def solution(A, B):
    if A==B:
        return 0
    for i in range(1,len(A)):
        if B == (A[-i:]+A[:-i]):
            return i
    return -1


# 같은 숫자는 싫어 문제풀이
def solution(arr):
    answer = []
    for i in arr:
        if len(answer)==0:
            answer.append(i)
        else:
            if answer[-1]!=i:
                answer.append(i)
    return answer


# 최댓값과 최솟값 문제풀이
def solution(s):
    splitted = list(map(int, s.split(" ")))
    answer = str(min(splitted))+" "+str(max(splitted))
    return answer


# 올바른 괄호 문제풀이
def solution(s):
    a = 0
    for i in s:
        if i==")":
            if a==0:
                return False
            else:
                a-=1
        else:
            a+=1
    if a>0:
        return False
    else:
        return True


# 문자열 나누기 문제풀이
def solution(s):
    current = ""
    same = 0
    diff = 0
    temp = 0
    for i in s:
        if current=="":
            current = i
            same += 1
            temp += 1
        else:
            if i==current:
                same+=1
            else:
                diff+=1
            if same==diff:
                current=""
    return temp


# 비밀지도 문제풀이
# 첫번째 방법
def solution(n, arr1, arr2):
    answer = []
    for i in range(n):
        answer_line = ""
        for j in range(n):
            if (arr1[i]%2) or (arr2[i]%2):
                answer_line = "#" + answer_line
            else:
                answer_line = " " + answer_line
            arr1[i] //= 2
            arr2[i] //= 2
        answer.append(answer_line)
    return answer
# 두번째 방법
def solution(n, arr1, arr2):
    answer = []
    for i in range(n):
        answer.append(bin(arr1[i]|arr2[i])[2:].zfill(n).replace("1","#").replace("0"," "))
    return answer


# 키패드 누르기 문제풀이
def get_distance(a,b):
    if a==0:
        a=11
    if b==0:
        b=11
    r_distance = abs((a-1)//3 - (b-1)//3)
    c_distance = abs((a-1)%3 - (b-1)%3)
    return r_distance + c_distance

def solution(numbers, hand):
    print(get_distance(5, 9))
    answer = ''
    current_left = 10
    current_right = 12
    for n in numbers:
        if n in [1,4,7]:
            answer += 'L'
            current_left = n
        elif n in [3,6,9]:
            answer += 'R'
            current_right = n
        elif n in [2,5,8,0]:
            l = get_distance(current_left, n)
            r = get_distance(current_right, n)
            if l<r:
                answer += 'L'
                current_left = n
            elif r<l:
                answer += 'R'
                current_right = n
            else:
                if hand == "left":
                    answer += 'L'
                    current_left = n
                else:
                    answer += 'R'
                    current_right = n
    return answer