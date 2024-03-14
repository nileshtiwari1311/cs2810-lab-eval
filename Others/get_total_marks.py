import os
import re

pattern = r'(\d+)\s*:\s*(PASS|FAIL)\s*:\s*(\d+)'

marks_mapping = [
{
    1: 1,
    2: 1,
    3: 2,
    4: 2,
    5: 2,
    6: 2,
    7: 2, 
    8: 2,
    9: 3,
    10: 3,
            },
]

def get_marks(filename, qno):
    total = 0
    if qno < 1 or qno > len(marks_mapping):
        return total

    with open(filename) as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                id, _ , status = match.groups()
                if int(id) in marks_mapping[qno-1] :
                    total += marks_mapping[qno-1][int(id)] * int(status)
    return total

if __name__ == "__main__":
    if os.path.isdir('./results') :
        q_dirs = sorted(os.listdir('./results'))

        for qno in q_dirs:
            print(f'{qno}\n--')
            files = sorted(os.listdir('./results/'+qno))

            for filename in files:
                match = re.search(r'\.txt$', filename)
                if match:
                    marks = get_marks('./results/'+qno+'/'+filename, int(qno[-1]))
                    print(f'{os.path.splitext(filename)[0]} : {marks}')