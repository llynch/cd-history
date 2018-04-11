#!/usr/bin/env python

import unittest
from cd_history import Cdh


history = ['/home/lynch/git', '/home/lynch/git/cd-history']


class TestCdh(unittest.TestCase):
    def test_list(self):
        Cdh().list(history)

    def test_search(self):
        Cdh().search(history, args=['i'])
