# test/exposure/model/album_test.rb
# frozen_string_literal: true

require_relative '../test_helper'
require_relative 'dummy'

class AlbumModelTest < Minitest::Test
  # =========================================================================
  # FAIL CASE 1: Chronological sorting for new discovered files (Orphans)
  # Expected: New files must be sorted by created_at, NOT just appended to the end.
  # =========================================================================
  def test_merge_inserts_new_disk_images_in_chronological_order
    # Sequence on drive (ordered chronologically by creation time)
    time_base = Time.now
    img_early = Dummy.make_image(filename: 'early_bird.jpg', created_at: time_base - 100)
    img_mid   = Dummy.make_image(filename: 'mid_photo.jpg',  created_at: time_base)
    img_late  = Dummy.make_image(filename: 'late_shot.jpg',  created_at: time_base + 100)

    # Reference state reads all 3 physical files from disk
    reference_album = Dummy.make_album(images: [img_early, img_mid, img_late])

    # Saved state only knows about the 'mid_photo.jpg' (e.g., other files were just added to disk)
    saved_album = Dummy.make_album(images: [img_mid])

    # Act
    merged = reference_album.merge(saved_album)

    # Assert: The final timeline MUST be strictly chronological: early -> mid -> late
    # CURRENT CODE FAILS: it puts ['mid_photo.jpg', 'early_bird.jpg', 'late_shot.jpg']
    expected_sequence = ['early_bird.jpg', 'mid_photo.jpg', 'late_shot.jpg']
    assert_equal expected_sequence, merged.images.map(&:filename)
  end

  def test_merge_does_not_duplicate_html_manifesto_guideline
    guideline = <<~HTML.strip
      <!--
      # -------------------------------------------------------------------
      # ARTIST MANIFESTO WORKSPACE
      # -------------------------------------------------------------------
      -->
    HTML
    
    author_story = "My deep personal manifestation statement text."
    
    reference_album = Dummy.make_album(story: "Write your creative narrative manifesto here...")
    
    # Simulate saved_album that already contains exactly one guideline and author text
    saved_album = Dummy.make_album(story: "#{guideline}\n\n#{author_story}")

    # Act: Merge states inside Domain Layer
    merged = reference_album.merge(saved_album)

    # Present: Simulate presenter cycle to see what goes into ALBUM.md
    payload = Exposure::Presenter::UserAlbum.new.call(merged)
    actual_md = payload[:md_content]

    # Assert: Ensure there is EXACTLY ONE guideline block in the final file content
    # We count occurrences of the opening comment tag
    occurrences = actual_md.scan("<!--").size
    assert_equal 1, occurrences, "The HTML guideline block must appear exactly once and never duplicate"
    
    # Ensure author's text is preserved completely
    assert_match author_story, actual_md
  end

  # =========================================================================
  # TEST 3: Handling physical deletion of assets from disk
  # Expected: If an asset exists in user's saved storyboard but has been
  # physically deleted from the storage drive, it must be completely 
  # dropped from the consolidated image collection to prevent broken links.
  # =========================================================================
  def test_merge_drops_assets_physically_deleted_from_drive
    # Reference album discovers ONLY photo1.jpg on disk (photo2.jpg was deleted)
    img_1 = Dummy.make_image(filename: 'photo1.jpg')
    reference_album = Dummy.make_album(images: [img_1])

    # Saved state still remembers both photos in its storyboard configuration
    img_2 = Dummy.make_image(filename: 'photo2.jpg', title: 'Deleted Photo')
    saved_album = Dummy.make_album(images: [img_2, img_1])

    # Act
    merged = reference_album.merge(saved_album)

    # Assert: The final sequence must ONLY contain photo1.jpg
    expected_filenames = ['photo1.jpg']
    assert_equal expected_filenames, merged.images.map(&:filename)
    
    # Ensure there are no nil elements lingering inside the array
    assert_equal 1, merged.images.size
  end
end
