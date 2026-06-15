document.addEventListener('DOMContentLoaded', () => {
  // ── Staggered Reveal Animations ──
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const parent = entry.target.closest('.features-grid, .tech-grid');
          if (parent) {
            const siblings = parent.querySelectorAll('.reveal-element');
            siblings.forEach((el, i) => {
              setTimeout(() => el.classList.add('revealed'), i * 100);
            });
          } else {
            entry.target.classList.add('revealed');
          }
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
  );

  document.querySelectorAll('.reveal-element').forEach((el) => {
    revealObserver.observe(el);
  });

  // ── Navbar scroll effect ──
  const navbar = document.getElementById('navbar');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      navbar?.classList.add('scrolled');
    } else {
      navbar?.classList.remove('scrolled');
    }
  });

  // ── Hamburger & Mobile Menu ──
  // Note: We use event delegation since the navbar is injected dynamically
  document.addEventListener('click', (e) => {
    const hamburger = document.getElementById('hamburger');
    const mobileMenu = document.getElementById('mobileMenu');
    
    if (e.target.closest('#hamburger')) {
      hamburger.classList.toggle('active');
      mobileMenu.classList.toggle('active');
    } else if (e.target.closest('.mobile-link') || !e.target.closest('#mobileMenu')) {
      hamburger?.classList.remove('active');
      mobileMenu?.classList.remove('active');
    }
  });

  // ── Canvas Particles floating background ──
  const canvas = document.getElementById('particles-canvas');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    let particles = [];
    
    const resizeCanvas = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    };
    
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();
    
    class Particle {
      constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * 2 + 1;
        this.speedX = Math.random() * 0.3 - 0.15;
        this.speedY = Math.random() * 0.3 - 0.15;
        this.opacity = Math.random() * 0.5 + 0.2;
      }
      
      update() {
        this.x += this.speedX;
        this.y += this.speedY;
        
        if (this.x < 0 || this.x > canvas.width) this.speedX *= -1;
        if (this.y < 0 || this.y > canvas.height) this.speedY *= -1;
      }
      
      draw() {
        ctx.fillStyle = `rgba(16, 185, 129, ${this.opacity})`;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
      }
    }
    
    const initParticles = () => {
      particles = [];
      const count = Math.min(Math.floor(canvas.width * canvas.height / 12000), 100);
      for (let i = 0; i < count; i++) {
        particles.push(new Particle());
      }
    };
    
    initParticles();
    
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      particles.forEach(p => {
        p.update();
        p.draw();
      });
      requestAnimationFrame(animate);
    };
    
    animate();
    
    // Re-initialize when window changes size significantly
    let resizeTimeout;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(initParticles, 200);
    });
  }
});
