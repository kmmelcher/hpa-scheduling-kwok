# Queries CPU and Memory usage of all running Docker containers for a given duration.

DURATION=$1
end=$((SECONDS + $DURATION)) 

echo "CPU%,MEM%"

while [ $SECONDS -lt $end ]; do
    docker stats --no-stream | awk '
    NR>1 {
        cpu_sum += substr($3, 1, length($3)-1)
        mem_sum += substr($7, 1, length($7)-1)
    }
    END {
        print cpu_sum","mem_sum
    }'
done