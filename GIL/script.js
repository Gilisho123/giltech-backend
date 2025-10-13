// Consolidated modal and form logic
document.addEventListener('DOMContentLoaded', () => {
  // Elements
  const hamburger = document.getElementById('hamburger');
  const nav = document.getElementById('nav');
  const modal = document.getElementById('modal');
  const modalPanel = modal && modal.querySelector('.modal-panel');
  const modalClose = document.getElementById('modalClose');
  const requestBtn = document.getElementById('requestBtn');
  const heroRequest = document.getElementById('heroRequest');
  const requestServiceButtons = document.querySelectorAll('.request-service');
  const modalForm = document.getElementById('modalForm');
  const requestForm = document.getElementById('requestForm');
  const modalMessage = document.getElementById('modalMessage');
  const serviceInput = document.getElementById('serviceInput');

  // Utility: safely set styles
  const showElement = (el) => { if (!el) return; el.style.display = 'block'; };
  const hideElement = (el) => { if (!el) return; el.style.display = 'none'; };

  // Hamburger nav toggle
  if (hamburger && nav) {
    hamburger.addEventListener('click', () => {
      const isOpen = nav.style.display === 'flex';
      nav.style.display = isOpen ? 'none' : 'flex';
    });
  }

  // Modal open/close
  function openModal(serviceText = '') {
    if (!modal) return;
    modal.setAttribute('aria-hidden', 'false');
    modal.style.display = 'flex';
    if (serviceText && serviceInput) serviceInput.value = serviceText;
    // hide any previous message
    hideElement(modalMessage);
    // focus first form control
    setTimeout(() => {
      const first = modal.querySelector('input, textarea, select, button');
      if (first) first.focus();
    }, 50);
  }

  function closeModal() {
    if (!modal) return;
    modal.setAttribute('aria-hidden', 'true');
    modal.style.display = 'none';
    hideElement(modalMessage);
    // Reset modal form so it's fresh next time
    if (modalForm) {
      modalForm.reset();
      clearFileInputs(modalForm);
    }
  }

  if (requestBtn) requestBtn.addEventListener('click', () => openModal(''));
  if (heroRequest) heroRequest.addEventListener('click', () => openModal('General Quote'));
  requestServiceButtons.forEach(btn => {
    btn.addEventListener('click', () => openModal(btn.dataset.service || ''));
  });

  if (modalClose) modalClose.addEventListener('click', closeModal);
  if (modal) {
    modal.addEventListener('click', (e) => { if (e.target === modal) closeModal(); });
  }
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape') closeModal(); });

  // Helper to clear file inputs
  function clearFileInputs(form) {
    if (!form) return;
    form.querySelectorAll('input[type=file]').forEach(input => {
      try { input.value = ''; } catch (err) { /* ignore */ }
      // For strict browsers, replace the node to ensure it's cleared
      if (input.files && input.files.length) {
        const parent = input.parentNode;
        // cloneNode(true) preserves attributes like class/name
        const clone = input.cloneNode(true);
        parent.replaceChild(clone, input);
      }
    });
  }

  // Show temporary message in modal
  function showModalMessage(text, opts = {}) {
    if (!modalMessage) return;
    modalMessage.innerText = text;
    modalMessage.style.color = opts.color || 'green';
    showElement(modalMessage);
  }

  // Modal form submission
  if (modalForm) {
    modalForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const submitBtn = modalForm.querySelector('button[type="submit"]');
      if (submitBtn) submitBtn.disabled = true;

      const formData = new FormData(modalForm);
      try {
        // Replace URL if your backend differs
        const res = await fetch('http://localhost:5000/api/requests', { method: 'POST', body: formData });
        const data = await res.json().catch(() => ({}));

        if (res.ok && (data.success || res.status === 200)) {
          showModalMessage('✅ Request submitted successfully!');
          // reset form and file inputs
          modalForm.reset();
          clearFileInputs(modalForm);
          // close modal after short delay so user sees message
          setTimeout(closeModal, 800);
        } else {
          const msg = data.message || 'Submission failed. Please try again.';
          showModalMessage('❌ ' + msg, { color: 'crimson' });
        }
      } catch (err) {
        console.error('Request error:', err);
        showModalMessage('⚠️ Could not connect to server.', { color: 'crimson' });
      } finally {
        if (submitBtn) submitBtn.disabled = false;
      }
    });
  }

  // Main page request form submission
  if (requestForm) {
    requestForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const submitBtn = requestForm.querySelector('button[type="submit"]');
      if (submitBtn) submitBtn.disabled = true;
      const formData = new FormData(requestForm);
      try {
        const res = await fetch('http://localhost:5000/api/requests', { method: 'POST', body: formData });
        const data = await res.json().catch(() => ({}));
        if (res.ok && (data.success || res.status === 200)) {
          alert('✅ Thank you! Your request has been received.');
          requestForm.reset();
        } else {
          alert('❌ Submission failed. Please try again.');
        }
      } catch (err) {
        console.error('Connection error:', err);
        alert('⚠️ Could not reach the server. Ensure backend is running.');
      } finally {
        if (submitBtn) submitBtn.disabled = false;
      }
    });
  }
});