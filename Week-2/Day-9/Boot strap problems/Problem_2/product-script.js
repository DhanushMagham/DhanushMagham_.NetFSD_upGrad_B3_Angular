document.addEventListener('DOMContentLoaded', function () {

  const cartButtons = document.querySelectorAll('.btn-add-cart');
  cartButtons.forEach(btn => {
    btn.addEventListener('click', function () {
      const title = this.closest('.card').querySelector('.card-title').textContent;
      alert(`${title} added to cart!`);
    });
  });


});