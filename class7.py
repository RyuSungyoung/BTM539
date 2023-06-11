class fish_bread: #붕어빵!
    # 제일 먼저 클래스명을 위와 같이 지정한다.
    # 그리고 우리는 클래스 내에 함수들을 정의하는데,
    # 이러한 함수들을 메서드라고 한다.
    # 해당 클래스만 쓸 수 있는 함수이다.
    flavor = "redbean"
    def print_flavor(self):
        #self 인스턴스 값을 호출하여 .flavor 변수를 담았음.
        print(self.flavor)

    def __init__(self, flavor="red bean"): #생성자: master class initializer
        # __init__ 메서드는 클래스를 이용해 인스턴스를 만들어낼 때 자동을 실행되는 메서드이다.
        # self는 인스턴스 자기 자신을 의미한다.
        self.flavor = flavor
        print("생성 완료!") #>> 작업이 되었음을 콘솔에 확인
        # self.flavor는 객체 내에 flavor라는 변수가 있고 거기에 어떠한 값을 담고 있다.
        # 이러한 것을 우리는 어트리뷰트(Attribute)라고 한다.
        # 즉, 객체의 특성이다.
        # 현재 우리는 붕어빵을 예시로 들고 있으니 붕어빵이 팥인지 슈크림인지 결정하는 특성이다.

    def change_flavor(self, flavor):
        # 해당 메서드는 어트리뷰트에 저장된 값을 변경해줄 때 쓰는 메서드이다.
        self.flavor = flavor

fb1 = fish_bread() #1. __init__ 클래스를 호출하여 fb1 생성
fb1.print_flavor #메서드 함수 실행 (이 두 개를 합쳐서 한번에! init)

fb1 = fish_bread("cream") #2. flavor에 cream을 할당
print(fb1.flavor)

fb1.change_flavor("cream") #3. change_flavor: flavor에 cream을 부여
print(fb1.flavor)

fb2 = fish_bread("cream")
print(fb2.flavor)


class Account:
    def __init__(self, name, number, pwd):
        self.name = name
        self.number = number
        self.__pwd = pwd #private: __(underscore*2)의 경우, 외부 액세스를 못하도록 처리한다.

    def change_pwd(self, new_pwd):
        # 은행 계좌로 예를 들면, 계좌 비밀번호는 필수 어트리뷰트이지만 외부에서 접근이 가능하다면 비밀번호가 노출이 될 것이다.
        # 따라서 내부에서만 사용하고 외부에 접근할 수 없는 어트리뷰트는 어트리뷰트 명 앞에 __를 붙인다.
        self.__pwd = new_pwd

new_acc = Account("JS", "12345678", "1234")

try:
    print(new_acc.__pwd)
except AttributeError as e:
    print("private attribute는 접근할 수 없습니다: ", e) #public <-> private(외부 열람이나 실행, 상속 x)
else:
    print("이게 되네...")


class Person:
    """조부모 클라쓰"""
    def __init__(self,name,age):
        self.name = name
        self.age = age
    
    def introduce(self):
        print("제 이름은 {}이고 제 나이는 {}살 입니다.".format(self.name, self.age))

class Student(Person):
    """부모 클라쓰"""
    def __init__(self,name,age,school):
        super().__init__(name,age) #super. : 모(母) class, super().init(name,age) = 모 클래스로부터 name과 age heritage
        #self.name = name
        #self.age = age >> heritage로 받은 variables는 super().__init__을 쓰면 기입할 필요 없다. 생략!
        self.school = school

    def introduce_student(self):
        print("제 이름은 {}이고 {}에 다니고 있으며 제 나이는 {}살 입니다.".format(self.name, self.school, self.age))

class GradStudent(Student):
    """손자 클라쓰"""
    def __init__(self,name,age,school,lab):
        super().__init__(name,age,school)
        self.lab = lab

    def introduce(self):
        print("제 이름은 {}이고 {}, {} Lab 소속이며 제 나이는 {}살 입니다.".format(self.name,self.school,self.lab,self.age))


human1 = Person("JS Kim", 27)
human1.introduce()

human2 = Student("JS Kim", 27, "KAIST")
human2.introduce()
human2.introduce_student()

human3 = GradStudent("JS Kim", 27, "KAIST", "MAC")
human3.introduce()
