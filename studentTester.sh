#!/usr/bin/env bash
refFolder=~/PA3_Grading/PA3_Final_Grading_ref # Change this var to w/e place you put the reference testers
gradeFile=./grades.txt
valgrindOutput=./valgrindOutput.txt

echo -e "Sanity check - Ref folder: $refFolder\n"

echo -e "Cleaning pwd\n"
make clean
rm student_fin_tester out*.txt temp.txt $gradeFile $valgrindOutput

echo -e "Generating ref files\n"
$refFolder/fin_tester $refFolder/shuffled_freq2.txt ./out_ref_0.txt 10 0 
$refFolder/fin_tester $refFolder/shuffled_freq2.txt ./out_ref_1.txt 10 1 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 10 4 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 20 4 
$refFolder/fin_tester $refFolder/shuffled_unique_freq_dict.txt ./out_ref_4.txt 50 4

echo -e "Copying over student_fin_tester.cpp\n"
cp $refFolder/student_fin_tester.cpp ./

echo -e "Compiling student_fin_tester\n"
g++ -g -gdwarf-2 -std=c++11 util.cpp DictionaryBST.cpp DictionaryHashtable.cpp DictionaryTrie.cpp student_fin_tester.cpp -o student_fin_tester

echo -e "Test 1: 26 single-char prefixes with runtime\n"
./student_fin_tester $refFolder/shuffled_freq2.txt out_student_0.txt 10 0 

echo -e "Test 2: 5 multi-char prefixes with runtime\n"
./student_fin_tester $refFolder/shuffled_freq2.txt out_student_1.txt 10 1

echo -e "Test 3: 5 multi-chra prefixes with 10 predictComp\n" 
./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 10 4 

echo -e "Test 4: 5 multi-chra prefixes with 20 predictComp\n"
./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 20 4 

echo -e "Test 5: 5 multi-chra prefixes with 50 predictComp\n"
./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt out_student_4.txt 50 4

echo -e "Test 6: Valgrind\n"
valgrind --leak-check=full ./student_fin_tester $refFolder/shuffled_freq_2.txt temp.txt 1 6 > temp.txt 2> $valgrindOutput
if grep -q "no leaks are possible" $valgrindOutput; then
  echo "2" > $gradeFile
else 
  echo "0" > $gradeFile
fi

echo -e "Test 7: Empty string\n"
./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt $gradeFile 10 6 > temp.txt

echo -e "Test 8: Fake string\n"
./student_fin_tester $refFolder/shuffled_unique_freq_dict.txt $gradeFile 10 7 > temp.txt

echo -e "Calc Grade\n"
$refFolder/fin_tester ./out_student_0.txt ./out_ref_0.txt $gradeFile 2  2> temp.txt
$refFolder/fin_tester ./out_student_1.txt ./out_ref_1.txt $gradeFile 3  2> temp.txt
$refFolder/fin_tester ./out_student_4.txt ./out_ref_4.txt $gradeFile 5  2> temp.txt

echo -e "Compile Benchdict\n"
g++ -g -gdwarf-2 -std=c++11 -Wall DictionaryBST.cpp DictionaryHashtable.cpp DictionaryTrie.cpp util.cpp benchdict.cpp -o benchdict

echo -e "Run benchdict\n"
./benchdict 50000 50000 5 $refFolder/shuffled_unique_freq_dict.txt 

echo -e "Displaying score in the order of:\n1. Valgrind\n2.Empty String\n3.Fake String\n4.Test 1\n5.Test 2\n6.Test 3-5\n######Note that score of Test 1 and 2 may be combined.######"
cat $gradeFile

tot=0
while read value 
do     
	tot=`echo "scale=3;${value} + ${tot}" | bc`
done < $gradeFile

echo -e "Total score: $tot/13\n"

echo -e "######Per Sriram, assign highest score between vocareum and ieng6 score######\n"
