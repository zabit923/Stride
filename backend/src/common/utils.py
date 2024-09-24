from django.http import HttpResponse


class CustomHttpResponseRedirect(HttpResponse):
    def __init__(self, redirect_to, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self['Location'] = redirect_to
        self.status_code = 302
