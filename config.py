class config:
	@staticmethod
	def getInstrFormat():
		return {
			# memory
			"alloca" : "{0} = alloca {1}", # 
			"store" : "{1} = {0} (store)",#"subneg {1},0,{0},NEXT",#
			"load" : "{0} = {1} (load)",

			#arithmetic
			"add" : "{0} = {1} + {2}",
			"subneg4" : "{0}\t{1}\t{2}\t{3}",

			
		}