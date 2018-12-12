from utils import bcolors

class Log(object):
	def __init__(self, message, level=0):
		self.message = str(message)
		self.level = level
	
	def color(self, string):
		if self.level == 0:
			return string
		elif self.level == 1:
			return bcolors.WARNING + string + bcolors.ENDC
		elif self.level == 2:
			return bcolors.FAIL + string + bcolors.ENDC
		elif self.level == 3:
			return bcolors.FAIL + bcolors.UNDERLINE + bcolors.BOLD + string + bcolors.ENDC + bcolors.ENDC + bcolors.ENDC
		elif self.level == 4:
			return bcolors.FAIL + bcolors.UNDERLINE + bcolors.BOLD + string + bcolors.ENDC + bcolors.ENDC + bcolors.ENDC
		else:
			return ""
	def __str__(self):
		return "- " + self.color(self.message)