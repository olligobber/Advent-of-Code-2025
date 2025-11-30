# Set up the folder and inputs for a day of Advent Of Code
# Will enter a bash prompt for the day's folder if it succeeds

# The first argument if provided is the day to set up, and defaults to the current day in local time
# The second argument if provided is the year to set up, and defaults to the current year in local time

# The session cookie for adventofcode.com should be located in ./session_cookie
# Go to "developer tools -> storage -> cookies" in a logged in firefox browser to get it
# Note your session cookie may change during a year,
# and the start will often look the same, so make sure to update it

if [ $# -gt 0 ]; then
	today=$(date -d "December $1" +%d)
	trimday=$(date -d "December $1" +%-d)
else
	today=$(date +%d)
	trimday=$(date +%-d)
fi

if [ $# -gt 1 ]; then
	year=$2
else
	year=$(date +%Y)
fi

# This won't work well if your local time zone isn't a whole number of hours plus or minus UTC
localunlocktime=$(date -d 'TZ="EST" 12am' +%-l%P)

echo "Setting up day $today for year $year"

# Check if the directory already exists
if [ -d "Day$today" ]; then
	echo "  Directory for day $today already exists!"
else
	# Make the directory
	mkdir "Day$today"
fi

# Go into the directory
cd "Day$today"

# Copy over the template files
if [ -f "makefile" ]; then
	echo "  Makefile already exists!"
else
	cat "../Template/makefile" | sed "s/Day/Day$today/g" | sed "s/Year/$year/g" > "makefile"
fi
if [ -f "Part1.typ" ]; then
	echo "  Source for part 1 already exists!"
else
	cp "../Template/Template.typ" "Part1.typ"
fi
if [ -f "Part2.typ" ]; then
	echo "  Source for part 2 already exists!"
else
	cp "../Template/Template.typ" "Part2.typ"
fi

# Check if input exists
if [ -f "input" ]; then
	echo "  Input data already exists!"

	# Run make watch to immediately compile both parts whenever changes are saved
	make watch
fi

# Check if session cookie is set up
if [ ! -f "../session_cookie" ]; then
	echo "Session cookie is missing, could not download input file."
	exit 1
fi

# Download the input file
cookie=$(cat ../session_cookie)
timeuntil=$(($(date -d "TZ=\"EST\" December $today $year 12am" +%s) - $(date +%s)))
if [ $timeuntil -gt 0 ]; then
	echo "Waiting until $localunlocktime to download input"
	sleep "$timeuntil"s
fi
echo "Downloading input now"
wget -q --header "Cookie: session=$cookie" "https://adventofcode.com/$year/day/$trimday/input"

# Report success/failure
if [ -f "input" ]; then
	echo "Download complete"
else
	echo "Download failed"
	exit 1
fi

# Run make watch to immediately compile both parts whenever changes are saved
make watch