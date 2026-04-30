# Segurese Backend API

This is the backend API for the Segurese Flutter app, responsible for sending form submissions via email to the appropriate departments.

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Configure email settings in `server.js`:
   - Set your SMTP host, port, user, and password.
   - For Gmail, use app password.

3. Set environment variables (optional):
   ```
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   ```

4. Run the server:
   ```
   npm start
   ```

The server will run on port 3000 by default.

## API Endpoint

### POST /submit-form

Submits a form and sends an email to the department.

**Form Data:**
- `categoria`: Category of the complaint
- `local`: Location (optional)
- `data`: Date (optional)
- `hora`: Time (optional)
- `descricao`: Description
- `emailDestino`: Destination email (optional, will use department mapping if not provided)
- `attachments`: File attachments (multiple)

**Response:**
- 200: Success
- 500: Error

## Department Email Mapping

The API maps categories to department emails. Update the `departmentEmails` object in `server.js` as needed.