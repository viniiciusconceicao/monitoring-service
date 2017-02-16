for i in `seq 1 9` ; do
  echo "-------------------slave--$i-------------------------"
   ssh slave$i "$1"
done
