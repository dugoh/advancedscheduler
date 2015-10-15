# Introduction #

The 'jil' utility reads commands in the Job Information Language format and applies them to the database as appropriate.

# Details #

The jil utility takes input conforming to the JilLanguageSpec and modifies the database accordingly.

Input is generally taken from STDIN, and output sent to STDOUT. 'jil' should return an error exit status if there is an error applying the changes. It should output a final message stating whether or not database changes were successful.