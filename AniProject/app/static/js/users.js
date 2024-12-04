const modal = document.getElementById("modal");
const closeButton = document.querySelector(".close");
const deleteButton = document.getElementById("deleteButton");
const userForm = document.getElementById("userForm");

document.getElementById("usersTable").addEventListener("click", function(e) {
    if (e.target.closest("tr") && !e.target.closest("th")) {
        const row = e.target.closest("tr");
        document.getElementById("userId").value = row.dataset.id;
        document.getElementById("username").value = row.dataset.username || '';
        document.getElementById("email").value = row.dataset.email || '';
        document.getElementById("phone").value = row.dataset.phone || '';

        const roleValue = row.dataset.role === 'Admin' ? '1' : '2';
        document.getElementById("role").value = roleValue;

        modal.style.display = "block";
    }
});

closeButton.addEventListener("click", function() {
    modal.style.display = "none";
});

deleteButton.addEventListener("click", function() {
    const userId = document.getElementById("userId").value;
    if (confirm("Вы уверены, что хотите удалить пользователя?")) {
        fetch(`/admin/users/delete/${userId}`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                }
            })
            .then(response => {
                if (response.ok) {
                    console.log("Пользователь удалён");
                    location.reload();
                } else {
                    alert("Ошибка при удалении пользователя");
                }
            });
    }
});

userForm.addEventListener("submit", function(e) {
    e.preventDefault();
    const userId = document.getElementById("userId").value;
    const data = {
        username: document.getElementById("username").value,
        email: document.getElementById("email").value,
        phone: document.getElementById("phone").value,
        role_id: document.getElementById("role").value
    };
    fetch(`/admin/users/edit/${userId}`, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        })
        .then(response => {
            if (response.ok) {
                alert("Данные пользователя обновлены");
                location.reload();
            } else {
                alert("Ошибка при обновлении данных пользователя");
            }
        });
});

window.addEventListener("click", function(e) {
    if (e.target == modal) {
        modal.style.display = "none";
    }
});

window.addEventListener("keydown", function(e) {
    if (e.key === "Escape" && modal.style.display == "block") {
        modal.style.display = "none";
    }
});