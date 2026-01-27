use rustler::{NifStruct, NifUnitEnum};
use rustler::{Env, Resource, ResourceArc, Term, NifResult};
use trackforge::trackers::byte_track::ByteTrack;
use std::sync::Mutex;

rustler::atoms! { error, ok, }

#[derive(Debug, Clone, NifStruct)]
#[module = "TrackForgex.Utils.BBox"]
struct BBox {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
}

#[derive(Debug, Clone, NifStruct)]
#[module = "TrackForgex.Utils.Detection"]
struct Detection {
    bbox: BBox,
    score: f32,
    class_id: i64,
}

struct ByteTrackInstance {
    tracker: Mutex<ByteTrack>,
}

impl Resource for ByteTrackInstance {}

#[derive(Debug, NifStruct)]
#[module = "TrackForgex.Trackers.ByteTrack.Settings"]
struct ByteTrackSettings {
    /// Threshold for high confidence detections (e.g., 0.5 or 0.6).
    track_thresh: f32,
    /// Number of frames to keep a lost track alive (e.g., 30).
    track_buffer: usize,
    /// IoU threshold for matching (e.g., 0.8).
    match_thresh: f32,
    /// Threshold for initializing a new track (usually same as or slightly lower than track_thresh).
    det_thresh: f32,
}

#[rustler::nif]
fn create_byte_track(settings: ByteTrackSettings) -> ResourceArc<ByteTrackInstance> {
    let tracker = ByteTrack::new(
        settings.track_thresh,
        settings.track_buffer,
        settings.match_thresh,
        settings.det_thresh,
    );
    ResourceArc::new(ByteTrackInstance {
        tracker: Mutex::new(tracker),
    })
}

#[derive(Debug, Clone, PartialEq, Eq, Copy, NifUnitEnum)]
pub enum ByteTrackerDetectionState {
    New,
    Tracked,
    Lost,
    Removed,
}

#[derive(Debug, Clone, NifStruct)]
#[module = "TrackForgex.Trackers.ByteTrack.DetectionResult"]
struct ByteTrackDetectionResult {
    /// Bounding
    bbox: BBox,
    /// Detection confidence score.
    score: f32,
    /// Class ID of the object.
    class_id: i64,
    /// Unique track ID.
    track_id: u64,
    /// Current tracking state (New, Tracked, Lost, Removed).
    state: ByteTrackerDetectionState,
    /// Whether the track is currently activated (confirmed).
    is_activated: bool,
    /// Current frame ID.
    frame_id: usize,
    /// Frame ID where the track started.
    start_frame: usize,
    /// Length of the tracklet (number of frames tracked).
    tracklet_len: usize
}

#[rustler::nif]
fn byte_track_update(
    instance: ResourceArc<ByteTrackInstance>,
    detections: Vec<Detection>,
) -> NifResult<Vec<ByteTrackDetectionResult>> {
    let detections_converted: Vec<([f32; 4], f32, i64)> = detections
        .into_iter()
        .map(|Detection { bbox, score, class_id }| {
            ([bbox.x, bbox.y, bbox.w, bbox.h], score, class_id)
        })
        .collect();

    let mut tracker = instance.tracker.lock().map_err(|_| rustler::Error::Term(Box::new("Mutex lock poisoned")))?;
    let results = tracker.update(detections_converted);
    let results_converted: Vec<ByteTrackDetectionResult> = results.into_iter().map(|result| {
        ByteTrackDetectionResult {
            bbox: BBox {
                x: result.tlwh[0],
                y: result.tlwh[1],
                w: result.tlwh[2],
                h: result.tlwh[3],
            },
            score: result.score,
            class_id: result.class_id,
            track_id: result.track_id,
            state: match result.state {
                trackforge::trackers::byte_track::TrackState::New => ByteTrackerDetectionState::New,
                trackforge::trackers::byte_track::TrackState::Tracked => ByteTrackerDetectionState::Tracked,
                trackforge::trackers::byte_track::TrackState::Lost => ByteTrackerDetectionState::Lost,
                trackforge::trackers::byte_track::TrackState::Removed => ByteTrackerDetectionState::Removed,
            },
            is_activated: result.is_activated,
            frame_id: result.frame_id,
            start_frame: result.start_frame,
            tracklet_len: result.tracklet_len,
        }
    }).collect();
    Ok(results_converted)
}


fn load(env: Env, _term: Term) -> bool {
    env.register::<ByteTrackInstance>().unwrap();
    true
}

rustler::init!("Elixir.TrackForgex.Native", load = load);
