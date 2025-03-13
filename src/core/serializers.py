from django.contrib.auth.hashers import make_password
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from core.models import User


class PasswordField(serializers.CharField):
    """Настройка полей ввода пароля"""

    def __init__(self, **kwargs):
        kwargs['style']={"input_type":'password'}  # Звездочки при вводе пароля
        kwargs.setdefault('write_only', True)  # Поле только для записи, не будет возвращаться в ответе api
        super().__init__(**kwargs)
        self.validators.append(validate_password)  # добавляется валидатор пароля к полю password


class CreateUserSerializer(serializers.ModelSerializer):
    """Сериализатор для модели пользователя User"""

    password = PasswordField(required=True)  # Добалено поле для пароля
    password_repeat = PasswordField(required=True)  # И поле для повторного ввода пароля

    class Meta:
        model = User
        fields = ("id", "username", "first_name", "last_name", "email", "password", "password_repeat")

    def validate(self, attrs: dict):
        """Метода для проверки совпадения пароля и его повторного ввода"""

        if attrs["password"] != attrs["password_repeat"]:
            raise ValidationError("Password must match")
        return attrs

    def create(self, validated_data: dict):
        """
        Перед созданием пользователя удаляет из validated_data поле password_repeat,
        чтобы оно не вошло в создаваемый объект пользователя. После чего шифрует пароль с помощью make_password
        """

        del validated_data["password_repeat"]
        validated_data["password"] = make_password(validated_data["password"])
        return super().create(validated_data)