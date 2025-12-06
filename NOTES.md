# Notes & Assumptions

## What I Built (In Simple Words)

### Task 1 - Database Tables

I created 3 tables to store data for a CRM system:

- **leads** - People who might become students (like contacts)
- **applications** - When a lead applies to a program
- **tasks** - Things counselors need to do (call someone, send email, review documents)

I also added rules so:

- A task must be linked to an application
- An application must be linked to a lead
- Task types can only be "call", "email", or "review"
- Due date can't be in the past

---

### Task 2 - Who Can See What (RLS Policies)

I set up security rules so:

- **Admins** can see all leads in their company
- **Counselors** can only see:
  - Leads they personally own, OR
  - Leads owned by their teammates

Think of it like: "You can see your own work and your team's work, but not other teams."

**Assumption Made:** The requirements said "Leads assigned to any team" but leads don't have a team column. So I interpreted this as "Leads owned by users in my team" - basically team visibility.

---

### Task 3 - Create Task API

I built an API endpoint that:

1. Takes in: which application, what type of task, when it's due
2. Checks everything is valid (correct type, future date)
3. Creates the task in the database
4. Returns success or error

It's like a "Create New Task" button that works behind the scenes.

---

### Task 4 - Today's Tasks Page

I built a simple webpage that:

1. Shows all tasks due TODAY that aren't completed yet
2. Displays task type, which application it's for, when it's due, and status
3. Has a "Mark Complete" button to finish a task

When you click "Mark Complete", it updates the database and refreshes the list.

---

### Task 5 - Stripe Payment Flow (Written Answer)

Explained how I would handle payments:

1. User clicks "Pay" → Save payment request in database
2. Create Stripe checkout session → Redirect user to Stripe
3. User pays on Stripe's page
4. Stripe sends us a webhook (notification) → We update our database
5. Mark application as "paid"

---

## Assumptions I Made

1. **No Supabase account created** - This is a code review, so I focused on writing correct code rather than deploying.

2. **Team visibility interpretation** - Since leads don't have a team_id, I assumed "team visibility" means you can see leads owned by your teammates.

3. **Date filtering** - Used local timezone for "today" calculation in the frontend.

4. **Task title** - Added optional title field to tasks for better identification.

---

## What Could Be Improved (Given More Time)

- Add loading states and better error messages
- Add optimistic updates (update UI before server confirms)
- Add pagination for large task lists
- Add unit tests
- Style the frontend page with CSS
