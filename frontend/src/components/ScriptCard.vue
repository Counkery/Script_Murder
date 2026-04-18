<template>
  <div class="card">
    <div class="row">
      <div>
        <h3>{{ script.title }}</h3>
        <div class="spacer"></div>
        <div>
          <span class="badge badge-info">{{ script.type || "类型未填" }}</span>
          <span class="badge badge-warning">
            难度：{{ script.difficulty || "未知" }}
          </span>
          <span class="badge">
            {{ script.minPlayers }}-{{ script.maxPlayers }} 人
          </span>
        </div>
      </div>
      <button class="primary-button" @click="onBookClick">
        预约一局
      </button>
    </div>
    <div class="spacer"></div>
    <p class="muted">
      {{ script.description || "暂时没有简介" }}
    </p>
    <div v-if="showBookingForm" class="spacer"></div>
    <div v-if="showBookingForm">
      <div class="field">
        <label>你的昵称</label>
        <input v-model="nickname" placeholder="例如：小李同学" />
      </div>
      <div class="field">
        <label>开局时间（本地时间）</label>
        <input v-model="startTime" type="datetime-local" />
      </div>
      <div class="spacer"></div>
      <button class="primary-button" :disabled="submitting" @click="submitBooking">
        {{ submitting ? "提交中..." : "确认预约" }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { ElMessage } from "element-plus";
import request from "../utils/request";

const props = defineProps({
  script: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(["booked"]);

const showBookingForm = ref(false);
const nickname = ref("");
const startTime = ref("");
const submitting = ref(false);

function onBookClick() {
  showBookingForm.value = !showBookingForm.value;
}

async function submitBooking() {
  if (!nickname.value || !startTime.value) {
    ElMessage.warning("请填写昵称和开局时间");
    return;
  }
  submitting.value = true;

  try {
    const user = await request.post("/users", {
      nickname: nickname.value
    });

    const booking = await request.post("/bookings", {
      userId: user.id,
      scriptId: props.script.id,
      startTime: new Date(startTime.value)
    });

    emit("booked", booking);
    ElMessage.success("预约成功！");
    showBookingForm.value = false;
  } catch (e) {
    // 具体错误已在拦截器中处理，这里只保证状态恢复
  } finally {
    submitting.value = false;
  }
}
</script>

