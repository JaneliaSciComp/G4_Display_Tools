% Run a unit test

test_suite = testsuite('fileTest.m');

test_results = run(test_suite);

disp(table(test_results))