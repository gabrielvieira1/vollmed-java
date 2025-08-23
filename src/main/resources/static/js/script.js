$("#deleteModal").on("show.bs.modal", function (e) {
  const modal = $(this);

  const id = $(e.relatedTarget).data("id");
  modal.find('input[name="id"]').val(id);

  const url = $(e.relatedTarget).data("url");
  modal.find("form").attr("action", url);
});

$("#updateModal").on("show.bs.modal", function (e) {
  const modal = $(this);

  const id = $(e.relatedTarget).data("id");
  modal.find('input[name="id"]').val(id);

  const url = $(e.relatedTarget).data("url");
  modal.find("form").attr("action", url);
});

document.addEventListener("DOMContentLoaded", function () {
  const especialidadeSelect = document.getElementById("especialidade");
  if (especialidadeSelect) {
    const medicoSelect = document.getElementById("idMedico");

    especialidadeSelect.addEventListener("change", function () {
      const especialidade = especialidadeSelect.value;

      medicoSelect.innerHTML = '<option value="">Selecione um médico</option>';

      if (especialidade) {
        fetch("/medicos/" + especialidade)
          .then((response) => {
            if (!response.ok) {
              throw new Error("Network response was not ok");
            }
            return response.json();
          })
          .then((data) => {
            data.forEach((medico) => {
              const option = document.createElement("option");
              option.value = medico.id;
              option.text = medico.nome;
              medicoSelect.appendChild(option);
            });
          })
          .catch((error) => console.error("Erro:", error));
      }
    });
  }

  // PDF Export functionality - seguindo padrão do projeto
  const pdfCheckboxes = document.querySelectorAll(".pdf-crypto-check");
  pdfCheckboxes.forEach(function (checkbox) {
    checkbox.addEventListener("change", function () {
      console.log("=== CHECKBOX PDF MUDOU ===");
      console.log("Checkbox marcado:", this.checked);

      const container = this.closest(".pdf-export-container");
      const link = container.querySelector(".pdf-link");
      const relatorioId = link.getAttribute("data-id");
      const criptografado = this.checked;

      console.log("Relatório ID:", relatorioId);
      console.log("Estado da criptografia:", criptografado);

      // Atualizar href do link
      const baseUrl = `/relatorios/${relatorioId}/exportar-pdf`;
      const novoHref = `${baseUrl}?criptografado=${criptografado}`;
      link.href = novoHref;

      console.log("Link atualizado para:", novoHref);

      // Feedback visual no emoji
      const emoji = this.nextElementSibling;
      if (criptografado) {
        emoji.style.color = "#28a745"; // Verde quando marcado
        emoji.textContent = "🔒";
      } else {
        emoji.style.color = "#666"; // Cinza quando desmarcado
        emoji.textContent = "🔓";
      }
    });
  });

  document.querySelectorAll(".pagination a.disabled").forEach(function (link) {
    link.addEventListener("click", function (event) {
      event.preventDefault();
    });
  });

  function openModal(modal) {
    modal.style.display = "block";
  }

  function closeModal(modal) {
    modal.style.display = "none";
  }

  function setupModalTriggers(modalId) {
    const modal = document.querySelector(modalId);

    document.querySelectorAll(`[href="${modalId}"]`).forEach((trigger) => {
      trigger.addEventListener("click", function (event) {
        event.preventDefault();
        const id = this.getAttribute("data-id");
        const url = this.getAttribute("data-url");
        modal.querySelector('input[name="id"]').value = id;
        modal.querySelector("form").setAttribute("action", url);
        openModal(modal);
      });
    });

    if (modal) {
      modal.querySelectorAll('[data-dismiss="modal"]').forEach((button) => {
        button.addEventListener("click", function () {
          closeModal(modal);
        });
      });

      modal.addEventListener("click", function (event) {
        if (event.target === modal) {
          closeModal(modal);
        }
      });
    }
  }

  setupModalTriggers("#deleteModal");
  setupModalTriggers("#updateModal");
});
