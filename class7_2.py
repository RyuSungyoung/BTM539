class Account:
    count = 0 #여기서 count = 최초선언

    def __init__(self, name, pwd):
        self.name = name
        Account.count += 1 #마스터 클래스에서의 함수 count: 증적변수 (+= 1) ex. OBS No.
        self.number = Account.count
        self.__pwd = pwd

    def change_pwd(self, new_pwd):
        self.__pwd = new_pwd

class Bank:
    def __init__(self,name):
        self.name = name
        self.accounts = []
    
    def makeAccount(self, user_name, account_pwd):
        self.accounts.append(Account(user_name, account_pwd))

    def number_of_count(self):
        return len(self.accounts)


bank1 = Bank("Kakao")
bank2 = Bank("Woori")

bank1.makeAccount("JS Kim", 1234)
bank1.makeAccount("MS Kim", 5678)
bank1.makeAccount("JS Choi", 4885)

bank2.makeAccount("JS Kim", 1234)
bank2.makeAccount("MS Kim", 5678)
bank2.makeAccount("JS Choi", 4885)

print(bank1.number_of_count())
print(bank2.number_of_count())
print(Account.count)

for i in bank1.accounts:
    print(i.number)

for i in bank2.accounts:
    print(i.number)