#!/bin/sh

test_description='git rebase -i --update-branches

This test runs git rebase, updating branch refs that point to commits
that are rebased.

Initial setup:

 A - B  (master)
  |\
  |  C      (linear-early)
  |    \
  |      D  (linear-late)
  |\
  |  E          (feat-e)
  |\   \
  |  F  |       (feat-f)
  |    \|
  |      G      (interim)
  |        \
  |          H  (my-dev, my-hotfixes)
   \
     I - J - fixup! I                 (fixup-early)
		      \
			K - fixup! J  (fixup-late)
'
. ./test-lib.sh

test_expect_success 'set up common' '
	test_commit A &&
	test_commit B
'

test_expect_success 'set up linear' '
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

test_expect_success 'set up merge' '
	git checkout -b feat-e A &&
	test_commit E &&
	git checkout -b feat-f A &&
	test_commit F &&
	git checkout -b interim &&
	test_merge G feat-e &&
	git checkout -b my-dev &&
	test_commit H &&
	git branch my-hotfixes
'

test_expect_success 'smoketest merge' '
	git rebase -r --update-branches master
'

test_expect_success 'check merge' '
	git rev-parse feat-e:B.t &&
	git rev-parse feat-f:B.t &&
	git rev-parse interim:B.t &&
	git rev-parse my-hotfixes:B.t
'

test_expect_success 'set up fixup' '
	git checkout -b fixup-early A &&
	test_commit I &&
	test_commit J &&
	test_commit "fixup! I" I.t.fix fix fixup-I &&
	git checkout -b fixup-late &&
	test_commit K &&
	test_commit "fixup! J" J.t.fix fix fixup-J
'

test_expect_success 'smoketest fixup' '
	git rebase --autosquash --update-branches master
'

test_expect_success 'check fixup' '
	git rev-parse fixup-early~:I.t.fix &&
	git rev-parse fixup-early:J.t.fix &&
	test -f K.t
'

test_done
