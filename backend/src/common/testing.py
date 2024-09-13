import random


def generate_phone_number():
    return f"+7 989 {(random.randint(1000000, 9999999))}"
