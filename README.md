# MovieHub

**MovieHub** is a project for working with movies that consists of a backend server and a mobile application.

## Project Structure

- **backend/** — server-side part of the application  
- **mobile/** — mobile application

## Running the Backend

1. Create a `.env` file in the root of the project based on `.env.example`:

cp .env.example .env

2. Start the backend using Docker:

docker-compose up --build -d

## Commit Message Rules

All commits in the project must follow the format below:

[MOVIE-#number_of_issue]: title of commit

description

### Example

[MOVIE-42]: add movie search endpoint

Implemented a new endpoint that allows searching movies by title and genre.

## Branch Naming Rules

- Branch names must follow the same pattern as commits: MOVIE-#number_of_task  
  Example: MOVIE-42

## Merging Rules

- When merging a branch into the main branch, use squash merge.  
- After merging, delete the source branch to keep the repository clean.
