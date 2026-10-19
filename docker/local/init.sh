#!/usr/bin/env bash
set -euo pipefail

python manage.py migrate --noinput
python manage.py loaddata initial_project_templates
python manage.py collectstatic --noinput
python manage.py shell <<'PY'
import os
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ["DJANGO_SUPERUSER_USERNAME"]
if not User.objects.filter(username=username).exists():
    user = User.objects.create_superuser(
        username=username,
        email=os.environ["DJANGO_SUPERUSER_EMAIL"],
        password=os.environ["DJANGO_SUPERUSER_PASSWORD"],
    )
    user.full_name = "Local admin"
    user.save(update_fields=["full_name"])
    print("Created local administrator:", username)
else:
    print("Local administrator already exists; password unchanged:", username)
PY
