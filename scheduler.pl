:- dynamic student/2.
:- dynamic room_capacity/2.
:- dynamic available_slots/1.

%--------
% Queries
%--------

%- 3.1
% clear_knowledge_base.
% Clears students, rooms and slots from knowledge base.
% Writes information about predicates deleted.
clear_knowledge_base:- sil1, nl, sil2, nl, sil3.

%- 3.2
% all_students(-StudentList).
% Makes a list of all student ID numbers.
all_students(L) :- findall(X, student(X,_), L).

%- 3.3
% all_courses(-CourseList).
% Makes a list of all unique courses.
% Takes the list of curriculums for each student, flattens the list so
% the list contains contents of each curriculum and then turns the
% list to a set so no duplicates remain.
all_courses(Set) :- findall(X, student(_,X), L), flatten(L, Flat), list_to_set(Flat, Set).

%- 3.4
% student_count(+CourseID, -StudentCount).
% Counts number of students registered to the given course.
student_count(CID, C) :- course_list(L), countr(L, CID, C), !.

%- 3.5
% common_students(+CourseID1,+CourseID2).
% Counts number of students registered to both courses.
common_students(CID1, CID2, C) :- courses_list(L), countr_common(L, CID1, CID2, C), !.

%- 3.6
% final_plan(-FinalPlan).
% Makes a final exam schedule from the list of all courses and Room, Slot pairs.
% Read documentation of fin/4 for more explanation on how it works.
final_plan(Plan) :- all_courses(Clist), room_slots(Pairs), fin(Clist, Pairs, Plan, []).

%- 3.7
% errors_for_plan(+FinalPlan, -ErrorCount).
% Counts the number of errors that are caused by conflicts
% and exams held in smaller rooms than needed.
errors_for_plan([[C, R, S]|Plan], ErrorCount) :-
  error1([[C, R, S]|Plan], E1), error2([C, R, S], Plan, E2),
  ErrorCount is E1 + E2.
%-----------------
% Other Predicates
%-----------------

% room_slots(-Pairs).
% Makes a list of [Room, Slot] pairs from the list of all rooms and slots.
room_slots(Pairs) :- all_rooms(Rooms), available_slots(Slots),
                    findall([Room, Slot], (member(Room, Rooms), member(Slot, Slots)), Pairs).
% all_rooms(-RoomList).
% Makes a list of all rooms.
all_rooms(L) :- findall(X, room_capacity(X,_), L).
% course_list(-CourseList).
% Makes a list of courses with copies for each time
% they appear on a student's curriculum
course_list(Flat) :- findall(X, student(_,X), L), flatten(L, Flat).
% courses_list(-CoursesList)
% Makes a list of student's curriculums. (A list of lists of courses they take.)
courses_list(L) :- findall(X, student(_,X), L).
% countr(+List, +Item, -Count).
% Counts how many times a spesific element appears on a list.
countr([],_, 0).
countr([X|T],X,N) :- countr(T,X,N1), N is N1 + 1, !.
countr([H|T],X, N) :- countr(T, X, N).
%%
% countr_common(+NestedList, +Item1, +Item2, -Count).
% Counts the number of lists that both item1 and item2 appears in.
countr_common([], _, _, 0). % Base case where the list is emtpy.
countr_common([H|T], X1, X2, N) :-  % Case 1
  member(X1, H), member(X2, H),     % If both item1 and item2 are in head list
  countr_common(T, X1, X2, N1),     % Count the times they appear in the tail list
  N is N1 + 1,                      % Increment this number by 1
  !.                                % Don't resatisfy Case 1

countr_common([_|T], X1, X2, N) :-  % Case 2
  countr_common(T, X1, X2, N).      % Head list does not contain both. Cotinue.


% roomerror(+Room, +Course, -ErrorCount).
% Counts the number of errors if exam for the given
% course is held at the given room.
roomerror(Room, Course, Error) :- % Case 1
  room_capacity(Room, Cap),       % Find the capacity of the room.
  student_count(Course, Atendee), % Find the nmber of atendees.
  Cap < Atendee,                  % Atendees do not fit to the room.
  Error is Atendee - Cap, !.      % Error goes up by NumberOfAttendee - RoomCapacity
roomerror(_, _, 0). % Atendee number is less than capacity. No error.

% error1(+FinalPlan, -ErrorCount).
% Counts the number of errors caused by room
% capacities for a given final plan.
error1([], 0).  % Base case where the list is empty.
error1([[Course, Room, _]|Plan], Error1) :- % Get current course and room
  roomerror(Room, Course, Error),           % Number of errors for current course and room
  error1(Plan, Error1p),                    % Count error for rest of the plan
  Error1 is Error1p + Error.                % Add current number of errors to that number

% error2(+Exam, +FinalPlan, -ErrorCount).
% Counts the number of errors caused by conflicts.
error2(_, [], 0). % Base case where the list is empty.
error2([C, R, S], [[C2, _, S]|Plan], N) :-  % Case 1 - Same slots
  common_students(C, C2, 0),                % Two courses have no common students.
  error2([C, R, S], Plan, N),               % Count errors for rest of the plan.
  !.                                        % Don't resatisfy Case 1

error2([C, R, S], [[C2, _, S]|Plan], N) :-  % Case 2 - Same slots
  common_students(C, C2, X), X > 0,         % Two courses have common students.
  error2([C, R, S], Plan, N1),              % Count errors for rest of the plan.
  N is N1+X,                                % Add number of common students to this number
  !.                                        % Don't resatisfy Case 2

error2([C, R, S], [[_, _, _]|Plan], N) :-  % Case 3
  error2([C, R, S], Plan, N).              % Different slots. Continue.

% fin(+CourseList, +RoomSlotPairs, -FinalPlan, +PlanSoFar).
% Make a final exam schedule that contains no conflicts or errors.
fin([], _, Plan, Plan). % All courses exhausted, unify final plan with plansofar.
fin([Course|CourseList], Pairs, Plan, PlanInit) :-     % Take a course from course list.
  member([Room, Slot], Pairs),                         % Take a Room, Slot pair from list of pairs.
  delete(Pairs, [Room, Slot], PairsRem),               % Don't put another exam in the same room at same slot.
  % When this exam is added to final plan so far, is the error still 0?
  % Than continue making a final plan with this exam added to plan so far
  errors_for_plan([[Course, Room, Slot]|PlanInit], 0),
  fin(CourseList, PairsRem, Plan, [[Course, Room, Slot]|PlanInit]).

% sil1.
% Clear students from knowledge base. also write info about predicates deleted.
sil1 :-
  all_students(X), length(X, L), write("student/2: "),
  write(L), retractall(student(_,_)).
% sil2.
% Clear rooms from knowledge base. Also write info about predicates deleted.
sil2 :-
  all_rooms(X), length(X, L), write("room_capacity/2: "),
  write(L), retractall(room_capacity(_,_)).
% sil3.
% Clear slots from knowledge base. Also write info about predicates deleted.
sil3 :-
  findall(Q, available_slots(Q), X), length(X, L),
  write("available_slots/1: "), write(L), retractall(available_slots(_)).
