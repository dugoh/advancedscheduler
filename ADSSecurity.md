# Introduction #

ADS Provides a role-based permission scheme that allows certain classes of users only the access they need to accomplish their job duties.


# Details #

All permissions are handled by the database. There are three Postgres roles: ADSViewer, ADSOperator, and ADSAdmin.

ADSViewer is able to run autorep, but cannot modify anything. This is helpful for developers who are locked out of production but would like to see job reports.

ADSOperator is able to make update/delete/inserts to several of the tables for the sake of setting up jobs. This role cannot modify the available machines, and is not a super user.

ADSAdmin is the most powerful role. It can create machines, has grant privileges, and is a database superuser.

# Best Practice #

In order to set up a multi-user site, no one should ever log in as 'ads'. In fact, that login should probably be disabled after the product is set up.

Each user should have their own database userid, which will be a member of the appropriate role from the list above. The may then user their own password to log into the database. They'll need to put an entry into their $HOME/.pgpass file, which looks something like this:

General form:
> 

&lt;dbserver&gt;

:

&lt;dbport&gt;

:

&lt;adsdatabase&gt;

:

&lt;dbuserid&gt;

:

&lt;dbpassword&gt;



Example:

> localhost:5432:ads:dave:mypass
