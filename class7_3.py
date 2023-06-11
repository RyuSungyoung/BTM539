class Person:
    def __init__(self,name,age):
        self.name = name
        self.age = age
    
    def introduce(self):
        print("제 이름은 {}이고 제 나이는 {}살 입니다.".format(self.name, self.age))

class Student(Person):
    def __init__(self,name,age,school):
        super().__init__(name,age)
        self.school = school

    def introduce_self(self):
        super().introduce()
        print(f"학교: {self.school}")

class GradStudent(Student):
    def __init__(self,name,age,school,lab):
        super().__init__(name,age,school)
        self.lab = lab

    def introduce(self):
        super(Student, self).introduce()
        print(f"연구실: {self.lab}")

human1 = Person("JS Kim", 27)
human2 = Student("JS Kim", 27, "KAIST")
human3 = GradStudent("JS Kim", 27, "KAIST", "MAC")

human1.introduce()
human2.introduce()
human3.introduce()