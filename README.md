# Final Exam Scheduler

This prolog program contains queries for finding a final exam schedule without conflicts or errors in the schedule. It can also be modified easily to produce schedules with minimal number of errors.

This is a course project I made for learning logic programming paradigm in prolog.

### Running the app

You will need swi-prolog to run this project. Check http://www.swi-prolog.org/Download.html for more info on that.
You will also need a knowledge base to run queries on. A small example is given in kb.pl

* Run swi-prolog by typing `swipl scheduler.pl` in terminal/command line.
* Remember to consult knowledge base before running any queries by typing
`consult('filename').` on swi-prolog console.

# Queries

### clear_knowledge_base.
Clears students, rooms and slots from knowledge base.
Writes information about predicates deleted.

### all_students(-StudentList).
Makes a list of all student ID numbers.

### all_courses(-CourseList).
Makes a list of all unique courses.
Takes the list of curriculums for each student, flattens the list so
the list contains contents of each curriculum and then turns the
list to a set so no duplicates remain.

### student_count(+CourseID, -StudentCount).
Counts number of students registered to the given course.

### common_students(+CourseID1,+CourseID2).
Counts number of students registered to both courses.

### final_plan(-FinalPlan).
Makes a final exam schedule from the list of all courses and Room, Slot pairs.
Read documentation of fin/4 for more explanation on how it works.

### errors_for_plan(+FinalPlan, -ErrorCount).
Counts the number of errors that are caused by conflicts
and exams held in smaller rooms than needed.

* Check out scheduler.pl for more predicates with interesting uses!
