// middleware/ensureAdmin.js
// Protect routes so only admins can access them.
// Behavior:
// 1. If `req.user` exists (e.g. set by session/auth middleware) and `req.user.isAdmin` is truthy -> allow.
// 2. Else, check Authorization: Bearer <token> or x-admin-token header and compare to process.env.ADMIN_TOKEN.
// 3. Otherwise, reject with 401 (Not authenticated) or 403 (Forbidden).

import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'dev_jwt_secret_change_me';

export default function ensureAdmin(req, res, next) {
  try {
    // Preferred: session-based user object set by your auth middleware
    if (req.user && req.user.isAdmin) {
      return next();
    }

    // JWT token fallback
    const authHeader = req.headers['authorization'] || '';
    if (authHeader.toLowerCase().startsWith('bearer ')) {
      const token = authHeader.slice(7).trim();
      if (token) {
        try {
          const payload = jwt.verify(token, JWT_SECRET);
          if (payload && payload.isAdmin) {
            req.user = payload;
            return next();
          }
        } catch (e) {
          // ignore jwt error and fall through to other checks
        }
      }
    }

    // Token-based fallback (use a long random token in ADMIN_TOKEN env)
    const envToken = process.env.ADMIN_TOKEN;
    if (envToken) {
      if (authHeader.toLowerCase().startsWith('bearer ')) {
        const token = authHeader.slice(7).trim();
        if (token && token === envToken) return next();
      }

      const headerToken = req.headers['x-admin-token'];
      if (headerToken && headerToken === envToken) return next();
    }

    // If we reach here, not authorized
    return res.status(401).json({ error: 'Not authenticated' });
  } catch (err) {
    console.error('ensureAdmin error', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
