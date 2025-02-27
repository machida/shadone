<template>
  <div id="youtubeloop">
    <youtube
      ref="youtube"
      :video-id="videoId"
      :player-vars="playerVars"
    ></youtube>
    <div>
      <label>URL:</label>
      <input v-model="url" type="url" />
    </div>
    <div>
      <label>Start from:</label>
      <input v-model.number="startMinute" type="number" min="0" />:<input
        v-model.number="startSecond"
        type="number"
        min="0"
      />
      <br />
      <label>End at:</label>
      <input v-model.number="endMinute" type="number" min="0" />:<input
        v-model.number="endSecond"
        type="number"
        min="0"
      />
    </div>
    <div>
      <label>Loop Count:</label>
      <input v-model.number="loopCount" type="number" min="1" />
    </div>
    <div>
      <label>Playback Speed:</label>
      <select v-model="playbackSpeed">
        <option v-for="item in selectItems" :key="item.id" :value="item.speed">
          {{ item.speed }}
        </option>
      </select>
    </div>
    <button v-if="!playing" @click="startLoop">Start</button>
    <button v-else @click="endLoop">Quit</button>
    <p>{{ remainingLoopCount }}</p>
  </div>
</template>

<script>
import Vue from 'vue'
import VueYoutube from 'vue-youtube'
import getYouTubeId from 'get-youtube-id'

Vue.use(VueYoutube)

export default {
  data() {
    return {
      playerVars: {
        rel: 0,
      },
      url: 'https://www.youtube.com/watch?v=lG0Ys-2d4MA',
      playing: false,
      startMinute: 0,
      startSecond: 0,
      endMinute: 0,
      endSecond: 0,
      loopCount: 1,
      remainingLoopCount: null,
      playbackSpeed: 1,
      selectItems: [
        { id: 1, speed: 0.25 },
        { id: 2, speed: 0.5 },
        { id: 3, speed: 0.75 },
        { id: 4, speed: 1 },
        { id: 5, speed: 1.25 },
        { id: 6, speed: 1.5 },
        { id: 7, speed: 1.75 },
        { id: 8, speed: 2 },
      ],
      intervalId: null,
    }
  },
  computed: {
    player() {
      return this.$refs.youtube.player
    },
    practiceDuration() {
      return (
        ((this.endTime - this.startTime) *
          (this.loopCount - this.remainingLoopCount)) /
        this.playbackSpeed
      )
    },
    startTime() {
      return this.startMinute * 60 + this.startSecond
    },
    endTime() {
      return this.endMinute * 60 + this.endSecond
    },
    videoId() {
      return getYouTubeId(this.url)
    },
    durationOfOneLoop() {
      return ((this.endTime - this.startTime + 1) / this.playbackSpeed) * 1000
    },
  },
  watch: {
    url(newUrl) {
      localStorage.url = newUrl
    },
    startMinute(newStartMinute) {
      localStorage.startMinute = newStartMinute
    },
    startSecond(newStartSecond) {
      localStorage.startSecond = newStartSecond
    },
    endMinute(newEndMinute) {
      localStorage.endMinute = newEndMinute
    },
    endSecond(newEndSecond) {
      localStorage.endSecond = newEndSecond
    },
    playbackSpeed(newPlaybackSpeed) {
      localStorage.playbackSpeed = newPlaybackSpeed
    },
    loopCount(newLoopCount) {
      localStorage.loopCount = newLoopCount
    },
  },
  created() {
    if (localStorage.url) {
      this.url = localStorage.url
    }
    if (localStorage.startMinute) {
      this.startMinute = Number(localStorage.startMinute)
    }
    if (localStorage.startSecond) {
      this.startSecond = Number(localStorage.startSecond)
    }
    if (localStorage.endMinute) {
      this.endMinute = Number(localStorage.endMinute)
    }
    if (localStorage.endSecond) {
      this.endSecond = Number(localStorage.endSecond)
    }
    if (localStorage.playbackSpeed) {
      this.playbackSpeed = Number(localStorage.playbackSpeed)
    }
    if (localStorage.loopCount) {
      this.loopCount = Number(localStorage.loopCount)
    }
  },
  methods: {
    startLoop() {
      this.playing = true
      this.setPlaybackRate()
      this.remainingLoopCount = this.loopCount
      this.intervalId = this.setLoop()
    },
    endLoop() {
      clearInterval(this.intervalId)
      this.player.pauseVideo()
      this.playing = false
      this.createPracticeLog()
    },
    setPlaybackRate() {
      this.player.setPlaybackRate(this.playbackSpeed)
    },
    setLoop() {
      const eachLoop = () => {
        this.player.seekTo(this.startTime)
        this.player.playVideo()
      }
      eachLoop()
      return setInterval(() => {
        this.remainingLoopCount--
        if (this.remainingLoopCount === 0) {
          this.endLoop()
          return
        }
        eachLoop()
      }, this.durationOfOneLoop)
    },
    createPracticeLog() {
      const practiceLog = {
        url: this.url,
        duration: this.practiceDuration,
      }
      this.$emit('loop-done', practiceLog)
    },
  },
}
</script>
