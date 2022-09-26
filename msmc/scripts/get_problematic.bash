
#get range of value for a given spot
cd ../plot
rm row_*
rm *problematic.txt
#remove the first two rows and renumber the file
#paste column into file

length=$(cat combined_boot_1.final.txt | wc -l)
if [[ $length -lt 29 ]];
then
	echo "Files previously trimmed"
else
	for i in $(ls combined_boot*)
	do
		cat $i | sed '2d' | sed '2d' | sed '2d' | sed '2d' | sed '2d' | cut -f2- > $i.processing.txt # change this to remove 3 rows
		rm $i
		paste column_one.txt $i.processing.txt > $i
		rm $i.processing.txt
	done
fi


for x in {2..28}
do
	for i in $(ls combined_boot*)
	do
		line=$(cat $i | head -$x | tail -1)
		echo "$line	$i"
	done >> row_$x.txt
done

for i in $(ls row*.txt)
do
	counter=1
	for x in $(cut -f4 $i)
	do
		z=$(echo $x | cut -d"." -f1)
		if [[ "$z" -gt "15000" ]];
		then
			output_file=$(cat $i | cut -f7 | head -$counter | tail -1 | cut -d"." -f1)
			output_file+=".problematic.txt"
			echo "Lambda_00 is $x at $i, which may be high" >> $output_file
			let "counter++"
		else
			let "counter++"
		fi
	done

	counter=1
	for x in $(cut -f5 $i)
	do
		z=$(echo $x | cut -d"." -f1)
                if [[ "$z" -gt "15000" ]];
                then
                        output_file=$(cat $i | cut -f7 | head -$counter | tail -1 | cut -d"." -f1)
                        output_file+=".problematic.txt"
                        echo "Lambda_01 is $x at $i, which may be high" >> $output_file
                        let "counter++"
                else
                        let "counter++"
                fi	
	done

	counter=1
        for x in $(cut -f6 $i)
	do
		z=$(echo $x | cut -d"." -f1)
                if [[ "$z" -gt "15000" ]];
                then
                        output_file=$(cat $i | cut -f7 | head -$counter | tail -1 | cut -d"." -f1)
                        output_file+=".problematic.txt"
                        echo "Lambda_11 is $x at $i, which may be high" >> $output_file
                        let "counter++"
                else
                        let "counter++"
                fi 
	done
done


			
head -1 combined_boot_10.final.txt > combined.final.txt
for i in {2..28}
do
	left_time_boundary=$(awk '{ total += $2; count++ } END { print total/count }' row_$i.txt)
	right_time_boundary=$(awk '{ total += $3; count++ } END { print total/count }' row_$i.txt)
	lambda_00=$(awk '{ total += $4; count++ } END { print total/count }' row_$i.txt)
	lambda_01=$(awk '{ total += $5; count++ } END { print total/count }' row_$i.txt)
	lambda_11=$(awk '{ total += $6; count++ } END { print total/count }' row_$i.txt)
	time_index="$(($i-2))"
	echo "$time_index	$left_time_boundary	$right_time_boundary	$lambda_00	$lambda_01	$lambda_11" >> combined.final.txt

done


