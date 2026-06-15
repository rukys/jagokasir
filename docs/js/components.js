/**
 * JagoKasir Landing Page Components
 * Handles reusable Header and Footer injection
 */

const components = {
  navbar: `
    <nav class="navbar" id="navbar">
        <div class="container">
            <a href="index.html" class="logo">
                <span class="logo-icon"><img src="assets/images/jagokasirlogo.png" alt="JagoKasir"></span>
                <span class="logo-text">JagoKasir</span>
            </a>
            <ul class="nav-links">
                <li><a href="index.html#features">Fitur</a></li>
                <li><a href="index.html#screenshots">Tampilan</a></li>
                <li><a href="index.html#tech">Teknologi</a></li>
                <li><a href="guide.html">Panduan</a></li>
                <li><a href="privacy.html">Privasi</a></li>
                <li><a href="https://github.com/rukys/jagokasir" class="btn-github"><i data-lucide="github"></i> GitHub</a></li>
            </ul>
            <button class="hamburger" id="hamburger" aria-label="Menu">
                <span></span>
                <span></span>
                <span></span>
            </button>
        </div>
    </nav>

    <div class="mobile-menu" id="mobileMenu">
        <a href="index.html#features" class="mobile-link">Fitur</a>
        <a href="index.html#screenshots" class="mobile-link">Tampilan</a>
        <a href="index.html#tech" class="mobile-link">Teknologi</a>
        <a href="guide.html" class="mobile-link">Panduan</a>
        <a href="privacy.html" class="mobile-link">Privasi</a>
        <a href="https://github.com/rukys/jagokasir" class="mobile-link">GitHub</a>
    </div>
    `,
  footer: `
    <footer class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-brand">
                    <div class="logo">
                        <span class="logo-icon"><img src="assets/images/jagokasirlogo.png" alt="JagoKasir"></span>
                        <span class="logo-text">JagoKasir</span>
                    </div>
                    <p class="brand-desc">Aplikasi kasir offline pintar untuk UMKM. Gratis, tanpa biaya langganan, dan data tetap aman 100% di perangkat Anda.</p>
                </div>
                <div class="footer-links">
                    <h4>Navigasi</h4>
                    <ul>
                        <li><a href="index.html#features">Fitur Utama</a></li>
                        <li><a href="index.html#screenshots">Tampilan Aplikasi</a></li>
                        <li><a href="guide.html">Panduan Pengguna</a></li>
                    </ul>
                </div>
                <div class="footer-links">
                    <h4>Legalitas & Kode</h4>
                    <ul>
                        <li><a href="privacy.html">Kebijakan Privasi</a></li>
                        <li><a href="https://github.com/rukys/jagokasir">Open Source Repository</a></li>
                    </ul>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; ${new Date().getFullYear()} JagoKasir. Dibuat untuk UMKM Indonesia.</p>
                <div class="footer-bottom-links">
                    <a href="privacy.html">Privasi</a>
                    <a href="guide.html">Panduan</a>
                    <a href="https://github.com/rukys/jagokasir">GitHub</a>
                </div>
            </div>
        </div>
    </footer>
  `
};

document.addEventListener('DOMContentLoaded', () => {
  // Inject navbar
  const navbarPlaceholder = document.getElementById('navbar-placeholder');
  if (navbarPlaceholder) {
    navbarPlaceholder.innerHTML = components.navbar;
    
    // Fix relative paths for nested pages if any, but since all pages are root, no changes needed.
    // If the path contains privacy.html or guide.html and we are currently on it, set active class
    const currentPath = window.location.pathname.split('/').pop() || 'index.html';
    const links = document.querySelectorAll('.nav-links a, .mobile-menu a');
    links.forEach(link => {
      const href = link.getAttribute('href');
      if (href === currentPath) {
        link.classList.add('active');
      }
    });
  }

  // Inject footer
  const footerPlaceholder = document.getElementById('footer-placeholder');
  if (footerPlaceholder) {
    footerPlaceholder.innerHTML = components.footer;
  }
  
  // Initialize Lucide Icons
  if (typeof lucide !== 'undefined') {
    lucide.createIcons();
  }
});
