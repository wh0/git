#!/bin/sh

test_description='git rebase --update-branches

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
	test_cmp_rev linear-early HEAD^
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
	test_cmp_rev feat-e HEAD^^2 &&
	test_cmp_rev feat-f HEAD^^ &&
	test_cmp_rev interim HEAD^ &&
	test_cmp_rev my-hotfixes HEAD
'

test_expect_success 'set up fixup' '
	git checkout -b fixup-early A &&
	test_commit I &&
	test_commit J &&
	test_commit "fixup! I" I.t II fixup-I &&
	git checkout -b fixup-late &&
	test_commit K &&
	test_commit "fixup! J" J.t JJ fixup-J
'

test_expect_success 'smoketest fixup' '
	git rebase -i --autosquash --update-branches master
'

test_expect_success 'check fixup' '
	test_cmp_rev fixup-early HEAD^ &&
	test_cmp_rev fixup-early^:I.t fixup-I:I.t &&
	test_cmp_rev fixup-early:J.t fixup-J:J.t &&
	test_cmp_rev HEAD:K.t K:K.t
'

test_done
