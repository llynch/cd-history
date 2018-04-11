#!/usr/bin/env python
# This is a python 2 program
# Try 2to3 for having a python 3 compatible one

import io, re, sys, os
import collections

# History file
history_file = os.path.expanduser('~/.cd_history')


try:
	unicode('test pyhon 2 or 3')
	def byte_to_string(bs):
		return bs

except:
	def unicode(s, encoding=None):
		return str(s)

	def byte_to_string(bs):
		return bs.encode('utf-8')


# Actions
class Cdh:
	def echo_stdout(self, history):
		"""Echo command parameters on stdout, useful for alias debugging"""
		sys.stdout.write(' '.join(sys.argv[2:]))
		return history

	def echo_stderr(self, history):
		"""Echo command parameters on stderr, useful for alias debugging"""
		sys.stderr.write(' '.join(sys.argv[2:]))
		return history

	def list(self, history):
		"""List the entire history"""
		i = 1
		for line in history:
			sys.stderr.write('%3d   %s\n' % (i, line))
			i += 1
		return history

	def add(self, history):
		"""Add specified directory or current if any to the history"""
		if len(sys.argv) > 2:
			try:
				os.chdir(''.join(sys.argv[2:]))
			except OSError as err:
				sys.stderr.write(err)
		history.add(unicode(os.getcwd(), 'utf-8'))
		return history

	def cleanup(self, history):
		missings = []

		for element in history:
			if not os.path.exists(element):
				missings.append(element)

		for missing in missings:
			print("Removing missing folder: %s" % missing)
			history.remove(missing)

		return history


	def search(self, history, args=None):
		"""Search specified pattern in the history"""
		results = list(history)
		results.sort()
		coloredresults = list(history)
		coloredresults.sort()
		color = 31
		sys.stderr.write('Searching for ')
		args = args or sys.argv[2:]
		for pattern in args:
			regexp = re.compile(pattern, re.IGNORECASE)
			sys.stderr.write(('\x1b[1;%dm%s\x1b[1;%dm ' % (color, pattern, 0)))
			subresults = []
			subcoloredresults = []
			nbresults = len(results)
			for i in range(nbresults):
				if regexp.search(coloredresults[i]):
					subcoloredresults.append(
						regexp.sub(('\x1b[1;%dm\g<0>\x1b[1;0m' % color), coloredresults[i])
					)
					subresults.append(results[i])
			results = subresults
			coloredresults = subcoloredresults
			color += 1

		if len(sys.argv) <= 2:
			sys.stderr.write('all directories')
		sys.stderr.write('\n')

		# Only one directory
		if len(results) == 1:
			print(results.pop())
			sys.stderr.write('Found in %s.\n' % coloredresults.pop())
			pass

		# No result
		elif len(results) == 0:
			sys.stdout.write('.')
			sys.stderr.write("No result.\n")

		# Choice to have
		else:
			i = 1
			for line in coloredresults:
				sys.stderr.write(u'%3d   %s\n' % (i, line))
				i += 1

			sys.stderr.write("Choose a directory : ",)
			try:
				a = int(sys.stdin.readline())
				if a > 0:
					a = a - 1
				sys.stdout.write(results[a])
				sys.stderr.write('OK.\n')
			except ValueError:
				sys.stdout.write('.')
				sys.stderr.write('Invalid number.\n')
			except IndexError:
				sys.stdout.write('.')
				sys.stderr.write('Unknowed entry.\n')
		return history

	def usage(self, history):
		"""Print usage"""
		sys.stderr.write('Usage : %s action\n' % sys.argv[0])
		sys.stderr.write('Where action could be :\n')
		for action in list(Cdh.__dict__.keys()):
			if isinstance(Cdh.__dict__[action], collections.Callable):
				sys.stderr.write('\t%s : %s\n' % (action, Cdh.__dict__[action].__doc__))
		return history


if __name__ == '__main__':
	try:
		# Reading history
		history = set()
		try:
			f = io.open(history_file)
			history = set([x.strip() for x in f.readlines()])
			f.close()
		except IOError:
			io.open(history_file, 'w').close() # touch

		# Ask the right method to handle
		cdh = Cdh()
		if len(sys.argv) > 1 and sys.argv[1] in Cdh.__dict__ and isinstance(Cdh.__dict__[sys.argv[1]], collections.Callable) :
			history = Cdh.__dict__[sys.argv[1]](cdh, history)
		else:
			history = cdh.usage(history)

		# Writing clean history
		try:
			f = io.open(history_file, 'w')
			for line in history:
				f.write(line)
				f.write(u'\n')
			f.close()
		except IOError:
			pass
	except KeyboardInterrupt:
		sys.stdout.write('.')
		sys.stderr.write('Interrupted.\n')

# vim: noet
