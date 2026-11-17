use std::{fs::create_dir_all, thread::sleep, time::Duration};

use floord::{SECURE, SOON_DELETED, cleanup_service};
use tempfile::tempdir_in;

const TEST_FILE: &str = "DELETE_PHASE";

// ------------------------------------------------------------------------------------------------
//      Deleting cleanup tests
// ------------------------------------------------------------------------------------------------

#[test]
fn dont_delete_by_both_times() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let probe = path.join(SOON_DELETED).join(TEST_FILE);
    create_dir_all(&probe).unwrap();

    cleanup_service(
        &vec![path],
        &Duration::new(5, 0),
        &Duration::new(5, 0),
        true,
    );

    assert!(probe.exists());
}

#[test]
fn delete_by_both_times_zero() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let probe = path.join(SOON_DELETED).join(TEST_FILE);
    create_dir_all(&probe).unwrap();

    cleanup_service(&vec![path], &Duration::ZERO, &Duration::ZERO, true);

    assert!(!probe.exists());
    assert!(probe.parent().unwrap().exists());
}

#[test]
fn delete_by_grace_time_zero() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let probe = path.join(SOON_DELETED).join(TEST_FILE);
    create_dir_all(&probe).unwrap();

    cleanup_service(
        &vec![path],
        &Duration::from_millis(50),
        &Duration::ZERO,
        true,
    );

    assert!(probe.exists());

    sleep(Duration::from_millis(1000));
    cleanup_service(
        &vec![path],
        &Duration::from_millis(50),
        &Duration::ZERO,
        true,
    );

    assert!(!probe.exists());
    assert!(probe.parent().unwrap().exists());
}

#[test]
fn delete_by_span_time_zero() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let probe = path.join(SOON_DELETED).join(TEST_FILE);
    create_dir_all(&probe).unwrap();

    cleanup_service(
        &vec![path],
        &Duration::ZERO,
        &Duration::from_millis(50),
        true,
    );

    assert!(probe.exists());

    sleep(Duration::from_millis(1000));
    cleanup_service(
        &vec![path],
        &Duration::ZERO,
        &Duration::from_millis(50),
        true,
    );

    assert!(!probe.exists());
    assert!(probe.parent().unwrap().exists());
}

#[test]
fn delete_by_summatory_times() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let probe = path.join(SOON_DELETED).join(TEST_FILE);
    create_dir_all(&probe).unwrap();

    cleanup_service(
        &vec![path],
        &Duration::from_millis(50),
        &Duration::from_millis(50),
        true,
    );
    assert!(probe.exists()); // May exist due to not wait

    sleep(Duration::from_millis(1000));
    cleanup_service(
        &vec![path],
        &Duration::from_millis(50),
        &Duration::from_millis(50),
        true,
    );

    assert!(!probe.exists()); // May NOT exist due to the wait
    assert!(probe.parent().unwrap().exists());
}

#[test]
fn dont_delete_secure_nor_soon_deleted_folders() {
    let path = tempdir_in(".").unwrap();
    let path = path.path();
    let secure = path.join(SECURE);
    create_dir_all(&secure).unwrap();
    let soon_deleted = path.join(SOON_DELETED);
    create_dir_all(&soon_deleted).unwrap();

    assert!(secure.exists());
    assert!(soon_deleted.exists());

    cleanup_service(&vec![path], &Duration::ZERO, &Duration::ZERO, true);

    assert!(secure.exists());
    assert!(soon_deleted.exists());
}
