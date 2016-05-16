#!/usr/bin/env bash
refFolder=~/PA3_Grading/PA3_Final_Grading_ref # Change this var to w/e place you put the reference testers
gradeFile=./grades.txt
valgrindOutput=./valgrindOutput.txt
timeoutVal=120

echo -e "## Sanity check - Ref folder: $refFolder\n"

###################################################################

echo -e "## Checking for student files in directory\n"

if [[ -f util.hpp ]] ; then
	echo "util.hpp exists in directory"
else
	echo "MISSING REQUIRED FILE: util.hpp . Exiting"
fi

if [[ -f util.cpp ]] ; then
	echo "util.cpp exists in directory"
else
	echo "MISSING REQUIRED FILE: util.cpp . Exiting"
fi

##################################################################

if [[ -f DictionaryBST.hpp ]] ; then
	echo "DictionaryBST.hpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryBST.hpp . Exiting"
fi

if [[ -f DictionaryBST.cpp ]] ; then
	echo "DictionaryBST.cpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryBST.cpp . Exiting"
fi

##################################################################

if [[ -f DictionaryHashtable.hpp ]] ; then
	echo "DictionaryHashtable.hpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryHashtable.hpp . Exiting"
fi

if [[ -f DictionaryHashtable.cpp ]] ; then
	echo "DictionaryHashtable.cpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryHashtable.cpp . Exiting"
fi

###################################################################

if [[ -f DictionaryTrie.hpp ]] ; then
	echo "DictionaryTrie.hpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryTrie.hpp . Exiting"
fi

if [[ -f DictionaryTrie.cpp ]] ; then
	echo "DictionaryTrie.cpp exists in directory"
else
	echo "MISSING REQUIRED FILE: DictionaryTrie.cpp . Exiting"
fi

###################################################################


if [[ -f FinalReport.pdf ]] ; then
	echo "FinalReport.pdf exists in directory. Make sure it is an actual PDF file"
else
	echo "MISSING REQUIRED FILE: FinalReport.pdf . Exiting"
fi

if [[ -f benchdict.cpp ]] ; then
	echo "benchdict.cpp exists in directory"
else
	echo "MISSING REQUIRED FILE: benchdict.cpp . Exiting"
fi

###################################################################
echo ""
echo -e "## Cleaning pwd\n"
make clean 
rm student_fin_tester out*.txt temp.txt $gradeFile $valgrindOutput 
echo ""
# Global variable for the student's score
studentScore=0

echo -e "## Generating ref files\n"
$refFolder/fin_tester $refFolder/shuffled_freq2.txt ./out_ref_0.txt 10 0 
$refFolder/fin_tester $refFolder/shuffled_freq2.txt ./out_ref_1.txt 10 1 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 10 4 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 20 4 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 50 4

echo -e "## Copying over student_fin_tester.cpp\n"
cp $refFolder/student_fin_tester.cpp ./

echo -e "## Compiling student_fin_tester\n"
g++ -g -gdwarf-2 -std=c++11 util.cpp DictionaryBST.cpp DictionaryHashtable.cpp DictionaryTrie.cpp student_fin_tester.cpp -o student_fin_tester
if [[ $? != 0 ]] ; then
	echo "Code does not compile."
	make clean > temp.txt
	rm -f temp.txt student_fin_tester.cpp
else
	TEMP_STATUS=0

	echo -e "## Test 1: 26 single-char prefixes with runtime\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_freq2.txt out_student_0.txt 10 0 &>temp.txt
	TEMP_STATUS=$?
	if [[ $TEMP_STATUS == 139 ]] ; then
		echo "Segmentation fault in all letters test!"
	elif [[ $TEMP_STATUS != 0 ]] ; then
		echo "Something went wrong in all letters test!"
	fi


	echo -e "## Test 2: 5 multi-char prefixes with runtime\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_freq2.txt out_student_1.txt 10 1 &>temp.txt
	TEMP_STATUS=$?
	if [[ $TEMP_STATUS == 139 ]] ; then
		echo "Segmentation fault in multi letters test!"
	elif [[ $TEMP_STATUS != 0 ]] ; then
		echo "Something went wrong in multi letters test!"
	fi


	echo -e "## Test 3: 5 multi-chra prefixes with size 10 predictComp\n" 
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 10 4 &> temp.txt
	TEMP_STATUS=$?
	if [[ $TEMP_STATUS == 139 ]] ; then
		echo "Segmentation fault in correctness test!"
	elif [[ $TEMP_STATUS != 0 ]] ; then
		echo "Something went wrong in correctness test!"
	fi


	echo -e "## Test 4: 5 multi-chra prefixes with size 20 predictComp\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 20 4 &> temp.txt
	TEMP_STATUS=$?
	if [[ $TEMP_STATUS == 139 ]] ; then
		echo "Segmentation fault in correctness test!"
	elif [[ $TEMP_STATUS != 0 ]] ; then
		echo "Something went wrong in correctness test!"
	fi


	echo -e "## Test 5: 5 multi-chra prefixes with 50 predictComp\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 50 4 &> temp.txt
	TEMP_STATUS=$?
	if [[ $TEMP_STATUS == 139 ]] ; then
		echo "Segmentation fault in correctness test!"
	elif [[ $TEMP_STATUS != 0 ]] ; then
		echo "Something went wrong in correctness test!"
	fi

	# Compare results and assign grades
	rm -f $gradeFile
	touch $gradeFile

	echo -e "## Test 6: Valgrind"
   	timeout $timeoutVal valgrind --leak-check=full ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt temp.txt 1 6 &> $valgrindOutput

	if grep -q "no leaks are possible" $valgrindOutput; then
	  echo "2" > $gradeFile
	  echo -e "No memory leaks!\n"
	else 
	  echo "0" > $gradeFile
	  echo -e "Memory leak found!\n"
	fi

	echo -e "## Test 7: Empty string\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt $gradeFile 10 6 &>temp.txt

	echo -e "## Test 8: Fake string\n"
	timeout $timeoutVal ./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt $gradeFile 10 7 &> temp.txt

	echo -e "## Calc Grade\n"
	if [[ -s out_student_0.txt ]] ; then
		timeout $timeoutVal ./student_fin_tester out_student_0.txt out_ref_0.txt grades.txt 2 2> temp.txt
	fi
	if [[ -s out_student_1.txt ]] ; then
		timeout $timeoutVal ./student_fin_tester out_student_1.txt out_ref_1.txt grades.txt 3 2> temp.txt
	fi
	if [[ -s out_student_4.txt ]] ; then
		timeout $timeoutVal ./student_fin_tester out_student_4.txt out_ref_4.txt grades.txt 5 2> temp.txt
	fi
	echo ""
	echo -e "## Displaying score in the order of:\n## 1. Valgrind\n## 2. Empty String\n## 3. Fake String\n## 4. Test 1\n## 5. Test 2\n## 6. Test 3-5\n###### Note that score of Test 1 and 2 may be combined. ######"
	cat $gradeFile

	IFS=$'\n'       # make newlines the only separator
	set -f          # disable globbing
	for i in $(cat $gradeFile); do
		studentScore=$(echo "scale=5; $studentScore+$i" | bc)
	done
fi

echo -e "##### Final score for code is $studentScore out of 13 #####\n"

make clean > temp.txt

echo -e "## Compile and Run Benchdict\n"
g++ -g -gdwarf-2 -std=c++11 -Wall DictionaryBST.cpp DictionaryHashtable.cpp DictionaryTrie.cpp util.cpp benchdict.cpp -o benchdict

timeout $timeoutVal ./benchdict 50000 50000 5 $refFolder/shuffled_unique_freq_dict.txt

echo -e "###### Per Sriram, assign highest score between vocareum and ieng6 score ######\n"
