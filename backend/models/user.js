const db = require('../db/connection');

class User {
  // Find a user by their ID
  static async findById(id) {
    try {
      const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by ID:', error);
      throw error;
    }
  }

  // Find a user by their UID (from OAuth)
  static async findByUid(uid) {
    try {
      const result = await db.query('SELECT * FROM users WHERE uid = $1', [uid]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by UID:', error);
      throw error;
    }
  }

  // Find a user by their email
  static async findByEmail(email) {
    try {
      const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by email:', error);
      throw error;
    }
  }

  // Get all users
  static async getAll() {
    try {
      const result = await db.query('SELECT * FROM users ORDER BY created_at DESC');
      return result.rows;
    } catch (error) {
      console.error('Error getting all users:', error);
      throw error;
    }
  }

  // Create a new user
  static async create(userData) {
    const { uid, email, display_name, role, status } = userData;
    
    try {
      const result = await db.query(
        'INSERT INTO users (uid, email, display_name, role, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [uid, email, display_name, role, status]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  // Update a user
  static async update(id, userData) {
    const { display_name, role, status } = userData;
    
    try {
      const result = await db.query(
        'UPDATE users SET display_name = $1, role = $2, status = $3, updated_at = CURRENT_TIMESTAMP WHERE id = $4 RETURNING *',
        [display_name, role, status, id]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  // Update user status
  static async updateStatus(id, status) {
    try {
      const result = await db.query(
        'UPDATE users SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
        [status, id]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating user status:', error);
      throw error;
    }
  }

  // Delete a user
  static async delete(id) {
    try {
      await db.query('DELETE FROM users WHERE id = $1', [id]);
      return true;
    } catch (error) {
      console.error('Error deleting user:', error);
      throw error;
    }
  }

  // Helper methods to check user roles
  static isAdmin(user) {
    return user && user.role === 'admin';
  }

  static isRepresentative(user) {
    return user && user.role === 'representative';
  }

  static isParticipant(user) {
    return user && user.role === 'participant';
  }

  // Helper methods to check user status
  static isApproved(user) {
    return user && user.status === 'approved';
  }

  static isPending(user) {
    return user && user.status === 'pending';
  }

  static isRejected(user) {
    return user && user.status === 'rejected';
  }
}

module.exports = User;
