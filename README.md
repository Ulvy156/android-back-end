
# 📚 SOP Knowledge Base – Database Design

This database supports the **Knowledge Base & SOP Viewer** mobile application.
It handles employee access, SOP documents, versioning, feedback, favorites, and compliance tracking.

The goal is to allow company staff to **securely view internal procedures (SOPs)** based on their **role and department**, while keeping a full audit trail of usage.

---

## 🧱 Core Entities

### 👤 User

Stores employee accounts.

Each user has:

* A role (Admin, HR, Staff)
* A department (HR, IT, Finance, etc)

Used to:

* Control access to documents
* Track activity
* Send notifications

---

### 📄 Document (SOP)

Represents an SOP or policy.

Contains:

* Title
* Description
* Department that owns it

A document does **not** store the file directly.
Instead, it uses **DocumentVersion** to track file updates.

---

### 🧾 DocumentVersion

Each SOP update is stored as a new version.

Stores:

* Version number (v1.0, v2.0, etc)
* PDF file URL
* Who uploaded it
* When it was uploaded

This allows:

* Viewing old SOPs
* Tracking changes
* Compliance auditing

---

### 🔐 DocumentPermission

Controls **who can access what**.

Each record links:

* A document
* A role (HR, Staff, Manager)

Example:

> “Only HR Managers can see HR Policies”

---

### ⭐ Favorite

Lets users bookmark SOPs for quick access.

Each user can favorite many documents, but only once per document.

---

### 💬 Feedback

Allows employees to:

* Suggest updates
* Report mistakes
* Request changes

Each feedback is linked to:

* A user
* A document

---

### 📜 ActivityLog

Tracks every important action for compliance.

Examples:

* VIEW_DOCUMENT
* DOWNLOAD
* SEARCH
* ADD_FAVORITE

This lets the company know:

> Who accessed what, and when.

---

### 🔔 Notification

Stores push notifications for users.

Used when:

* A new SOP is added
* An SOP is updated

Each notification is marked as read/unread.

---

## 🔗 How Everything Connects

* A **User** belongs to a role and department
* A **Document** belongs to a department
* A **Document** has many **DocumentVersions**
* A **Document** has many **Permissions** (who can view it)
* A **User** can:

  * Favorite documents
  * Give feedback
  * Generate activity logs
  * Receive notifications

---

## 🧠 Why this design works

This schema supports all required assignment features:

| Requirement                | Supported |
| -------------------------- | --------- |
| Role-based access          | ✅         |
| Department-based filtering | ✅         |
| SOP Versioning             | ✅         |
| PDF Storage                | ✅         |
| Feedback system            | ✅         |
| Favorites                  | ✅         |
| Notifications              | ✅         |
| Activity logging           | ✅         |
| Compliance tracking        | ✅         |

It’s simple enough for a student project, but structured enough to look like a real corporate system.

---

If you want, I can also generate:

* ER diagram explanation
* API endpoints list
* Or a DB schema section for your report 📊
