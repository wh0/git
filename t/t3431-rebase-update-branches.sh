#!/bin/sh

test_description='git rebase -i --update-branches

This test runs git rebase, updating branch refs that point to commits
that are rebased.

Initial setup:

 A - B          (master)
  |\
  |  C          (linear-early)
  |    \
  |      D      (linear-late)
  |\
  |  E          (feat-e)
   \   \
     F  |       (feat-f)
       \|
         G      (interim)
           \
             H  (my-dev)
'
. ./test-lib.sh

test_expect_success 'setup linear' '
	test_commit A &&
	test_commit B &&
	git checkout -b linear-early A &&
	test_commit C &&
	git checkout -b linear-late &&
	test_commit D
'

test_expect_success 'smoketest linear' '
	git rebase --update-branches master
'

test_expect_success 'check linear' '
	git rev-parse linear-early:B.t
'

test_expect_success 'setup merge' '
	git checkout -b feat-e A &&
	test_commit E &&
	git checkout -b feat-f A &&
	test_commit F &&
	git checkout -b interim &&
	test_merge G feat-e &&
	git checkout -b my-dev &&
	test_commit H
'

test_expect_success 'smoketest merge' '
	git rebase -r --update-branches master
'

test_expect_success 'check merge' '
	git rev-parse feat-e:B.t &&
	git rev-parse feat-f:B.t &&
	git rev-parse interim:B.t
'

test_done
