#!/usr/bin/env python

'''stores authentication cookies for HTTP repositories

To install, add the following to your mercurial.ini or .hgrc:

    [extensions]
    ...
    hgext.kilnauth=/path/to/kilnauth.py
    ...
'''

import os
from urllib2 import HTTPCookieProcessor
from cookielib import MozillaCookieJar, Cookie

import mercurial.url

def get_cookiejar():
    if os.name == 'nt':
        cookie_path = os.path.expanduser('~\\_hgcookies')
    else:
        cookie_path = os.path.expanduser('~/.hgcookies')
    cj = MozillaCookieJar(cookie_path)
    if not os.path.exists(cookie_path):
        cj.save()
    cj.load(ignore_discard=True, ignore_expires=True)
    return cj

def make_cookie(request, name, value):
    domain = request.get_host()
    if domain.count('.') == 0:
        domain += ".local"
    return Cookie(0, name, value, None, False, domain, False, False, '/', False, False, None, False, None, None, {}, False)

def reposetup(ui, repo):
    mercurial.url.opener_ = mercurial.url.opener

    def open_wrapper(func, cj):
        def open(*args, **kwargs):
            cj.set_cookie(make_cookie(args[0], 'fSetNewFogBugzAuthCookie', '1'))
            result = func(*args, **kwargs)
            cj.save(ignore_discard=True, ignore_expires=True)
            return result
        return open

    def opener(*args, **kwargs):
        cj = get_cookiejar()
        urlopener = mercurial.url.opener_(*args, **kwargs)
        urlopener.add_handler(HTTPCookieProcessor(cj))
        urlopener.open = open_wrapper(urlopener.open, cj)
        return urlopener

    mercurial.url.opener = opener

def logout(ui, repo, domain=None):
    """log out of http repositories
    
    Clears the cookies stored for HTTP repositories. If [domain] is
    specified, only that domain will be logged out. Otherwise,
    all domains will be logged out.
    """

    cj = get_cookiejar()
    try:
        cj.clear(domain=domain)
        cj.save()
    except KeyError:
        ui.write("Not logged in to '%s'\n" % (domain,))

cmdtable = {
    'logout': (logout, [], '[domain]')
}

